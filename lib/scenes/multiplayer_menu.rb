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
        username = edit_line Config.get(:player_username)#"cyberarm"
        label "Host:"
        @host = edit_line "#{Config.get(:player_last_host)}:#{Config.get(:player_last_port)}"#"localhost:56789"

        button "Connect" do |b|
          if @client && @client.connected? && !Game::Net::Client.token
            Game::Net::Client.instance = nil
            @client.disconnect
            @locked = false
          end

          unless @locked
            @tick   = Gosu.milliseconds
            host = @host.value.split(":").first
            port = @host.value.split(":").last

            @client = Game::Net::Client.new(host, Integer(port))
            Game::Net::Client.instance = @client
            if @client.connected?
              Config.set(:player_username, username.text.text)
              Config.set(:player_last_host, host)
              Config.set(:player_last_port, port)
              Config.save
              data = {username: username.text.text}
              @client.transmit("auth", "connect", data, GameOverseer::Client::HANDSHAKE)
            end

            @messages.color= Gosu::Color::YELLOW
            @messages.text = "Connecting..."

            @locked = true
          end
        end

        button "Cancel" do
          @client.disconnect if @client && @client.is_a?(Game::Net::Client)
          push_state(MainMenu)
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
        if defined?(@client) && @client.is_a?(Game::Net::Client)
          @client.update
          push_state(MultiplayerLobbyMenu) if @client.connected? && Game::Net::Client.token

          if Gosu.milliseconds-@tick >= 5_000 && !@client.connected?
            @client.disconnect
            host = @host.value.split(":").first
            port = @host.value.split(":").last

            @messages.color= Gosu::Color::RED
            @messages.text = "Connection to #{host}:#{port} failed."
            @locked = false
            @client = nil
          end
        end
      end
    end
  end
end
