module Game
  class Scene
    class MultiplayerLobbyMenu < Menu
      def prepare
        Game::Scene::MultiplayerLobbyMenu.instance = self
        @players = Game::Net::Lobby.instance.players
        @player_elements = []
        @_y = 400

        @client = Game::Net::Client.instance
        @client.transmit('lobby', 'join', {status: 200, token: Game::Net::Client.token}, GameOverseer::Client::WORLD, true)

        title "Ruby Sync Racing"
        label "Multiplayer Lobby", size: 50

        @status_button = button "Not Ready" do
          change_status
        end

        button "Leave" do
          @client.transmit('lobby', 'leave', {status: 200, token: Game::Net::Client.token}, GameOverseer::Client::WORLD, true)
          @client.disconnect
          push_game_state(MainMenu)
        end

        @peer_counter = label "Peers connected #{@players.count}/8", size: 40
      end

      def self.instance
        @instance
      end
      def self.instance=instance
        @instance=instance
      end

      def change_status
        case @status_button.text.text
        when "Ready"
          @status_button.text.text = "Not Ready"
          @client.transmit('lobby', 'ready', {status: 200, ready: false}, GameOverseer::Client::WORLD, true)

        when "Not Ready"
          @client.transmit('lobby', 'ready', {status: 200, ready: true}, GameOverseer::Client::WORLD, true)
          @status_button.text.text = "Ready"
        end
      end

      def start
        push_game_state(NetPlay)
      end

      def draw
        super
        @player_elements.each do |e|
          e.draw
          e.x = ($window.width/2)-(e.x/2)
        end
      end

      def update
        super
        @client.update(0)
        @players = Game::Net::Lobby.instance.players
        @peer_counter.text = "Peers connected #{@players.count}/#{8}" # replace 8 with actual # of max clients


        @players.each do |player|
          create = @player_elements.detect do |e|
            if player['username'] == e.text
              true
            end
          end

          unless create
            if player['username'] == Game::Net::Client.username
              @player_elements.push(Game::Text.new(player['username'], y: @_y, size: 26, color: Gosu::Color::BLUE))
            else
              @player_elements.push(Game::Text.new(player['username'], y: @_y, size: 26, color: Gosu::Color::GRAY))
            end

            @_y+=26
          end
        end

        @players.each do |player|
          @player_elements.each do |e|
            if player['ready']
              if player['username'] == Game::Net::Client.username
                e.color = Gosu::Color::YELLOW
              else
                e.color = Gosu::Color::WHITE
              end

            else
              if player['username'] == Game::Net::Client.username
                e.color = Gosu::Color::BLUE
              else
                e.color = Gosu::Color::GRAY
              end
            end
          end
        end

        @player_elements.each do |e|
          detected = @players.detect do |player|
            if e.text == player['username']
              true
            end
          end

          @player_elements.delete(e) unless detected
        end
      end
    end
  end
end
