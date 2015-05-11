module Game
  class Scene
    class MultiplayerMenu < Menu
      attr_reader :messages
      attr_accessor :lock

      def prepare
        MultiplayerMenu.instance = self
        @tick = 0
        @locked = false

        title "Ruby Sync Racing"
        label "Multiplayer", size: 50
        @messages = label ""

        label "Enter a Username:"
        username = edit_line "cyberarm"
        label "Host:"
        @host = edit_line "localhost"
        label "Port:"
        @port = edit_line "56789"

        button "Connect" do
          @tick   = 0
          Game::Net::Client.username = username.text.text

          @client = Game::Net::Client.new(@host.value, Integer(@port.value)) unless @locked
          Game::Net::Client.instance = @client
          if @client.connected?
            data = {username: Game::Net::Client.username}
            @client.transmit("auth", "connect", data, GameOverseer::Client::HANDSHAKE)
          end

          @locked = true
        end

        button "Disconnect" do
          if @locked
            @client.disconnect if @client && @client.is_a?(Game::Net::Client)
            @messages.text = "Disconnected."
            @locked = false
          else
            @messages.text = "Not connected to server."
          end
        end

        button "Cancel" do
          @client.disconnect if @client && @client.is_a?(Game::Net::Client)
          push_game_state(MainMenu)
        end
      end

      def self.instance
        @instance
      end
      def self.instance=instance
        @instance=instance
      end

      def update
        super
        @tick+=1

        if defined?(@client) && @client.is_a?(Game::Net::Client)
          @client.update
          push_game_state(MultiplayerLobbyMenu) if @client.connected? && Game::Net::Client.token

          if @tick >= 60*5 && !@client.connected?
            @client.disconnect
            @messages.text = "Connection to #{@host.value}:#{@port.value} failed."
            @locked = false
            @client = nil
          end
        end
      end
    end
  end
end
