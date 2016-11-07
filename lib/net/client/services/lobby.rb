module Game
  module Net
    class Lobby < GameOverseer::Client::Service
      attr_reader :players

      def setup
        register_channel("lobby")
        Game::Net::Lobby.instance = self
        @players = []
      end

      def self.instance
        @instance
      end

      def self.instance=instance
        @instance=instance
      end

      def process_data(data, channel)
        case data['mode']
        when 'player_joined'
          puts "joined"
          @players = data['data']['players']

        when 'ready'
          @players.detect do |hash|
            if data['data']['client_id'] == hash['client_id']
              hash['ready'] = data['data']['ready']
              true
            end
          end

        when 'start'
          puts "Everyones ready!"
          Game::Scene::MultiplayerLobbyMenu.instance.start



        when 'player_left'
          puts "left"
          @players.each do |hash|
            if hash['client_id'] == data['data']['client_id']
              @players.delete(hash)
            end
          end
        end
      end
    end
  end
end
