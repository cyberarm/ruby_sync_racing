module Game
  class Scene
    class NetPlay < Play
      attr_accessor :peer_cars

      def setup
        @net_tick = 0
        $window.show_cursor = false
        @client = Game::Net::Client.instance

        Game::Scene::NetPlay.instance = self

        @peer_cars = []

        @options[:carfile] = @options[:carfile] ? @options[:carfile] : "data/cars/test_car.json"
        super
      end

      def self.instance=instance
        @instance = instance
      end
      def self.instance
        @instance
      end

      def draw
        super
        @car.draw
        fill(@color)
        Game::Net::GamePlay.instance.players.each do |_car|
          next unless _car.angle
          _car.text.x = _car.x.to_f
          _car.text.y = _car.y.to_f
          _car.text.draw
          _car.image.draw_rot(_car.x.to_f, _car.y.to_f, 5, _car.angle)
        end
      end

      def update
        super
        @car.update

        tile = @track.collision.find(@car.x, @car.y)
        if tile
          @last_tile.color = nil if @last_tile != nil
          @last_tile = tile
          tile.color = Gosu::Color::GRAY
        end

        puts "Local Car Angle: #{@car.angle}"
        @client.transmit('game', 'player_moved', {angle: @car.angle, x: @car.x, y: @car.y, timestamp: Engine.timestamp}, GameOverseer::Client::WORLD, false)
        @client.update(0)
      end

      def button_up(id)
        case id
        when Gosu::KbEscape
          push_state(Pause.new(last_state: self))
        end
      end
    end
  end
end
