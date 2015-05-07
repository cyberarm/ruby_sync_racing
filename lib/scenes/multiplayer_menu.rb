module Game
  class Scene
    class MultiplayerMenu < Menu
      attr_reader :messages

      def prepare
        MultiplayerMenu.instance = self
        @tick = 0
        @locked = false

        title "Ruby Sync Racing"
        label "Multiplayer", size: 50
        label "Hey #{@options[:username].text.text.capitalize}"
        @messages = label ""

        label "Host:"
        @host = edit_line "localhost"
        label "Port:"
        @port = edit_line "56789"

        button "Connect" do
          @tick   = 0
          unless @locked
            @client = Game::Net::Client.new(@host.value, Integer(@port.value))
            if @client.connected?
              data = {username: @options[:username].text.text}
              @client.transmit("auth", "connect", data, GameOverseer::Client::HANDSHAKE)
            end
          else
            @messages.text = "Already connected to server."
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
