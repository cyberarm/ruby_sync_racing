module Game
  module Net
    class GamePlay < GameOverseer::Client::Service
      attr_reader :players

      def setup
        register_channel("game")
        Game::Net::GamePlay.instance = self
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
        when 'player_moved'
          data['data']['players'].each do |player|
            next if player['username'] == Game::Net::Client.username
            user = @players.detect {|_user| _user.client_id == player['client_id']}
            unless user
              car = Game::Net::Car.new
              car.text      = Text.new(player['username'], x: 0, y: 0)
              car.client_id = player['client_id']
              car.username  = player['username']
              car.angle     = player['angle']
              car.x         = player['x']
              car.y         = player['y']
              car.image     = Gosu::Image['assets/cars/CAR.png']

              @players.push(car)
            else
              @players.detect do |_user|
                if _user.client_id == player['client_id']
                  _user.angle = player['angle']
                  _user.x     = player['x']
                  _user.y     = player['y']
                  true
                end
              end
            end
          end

        when 'player_left'
          puts "left"
          @players.each do |hash|
            if hash.client_id == data['data']['client_id']
              @players.delete(hash)
            end
          end
        end
      end
    end
  end
end
