module Game
  class Scene
    class NetPlay < GameState
      attr_accessor :peer_cars

      def setup
        @net_tick = 0
        $window.show_cursor = false
        @client = Game::Net::Client.instance

        Game::Scene::NetPlay.instance = self

        @peer_cars = []

        @carfile = @options[:carfile] || "data/cars/test_car.json"

        @car = Car.create(x: $window.width/2, y: $window.height/2, spec: @carfile)
        @trackfile = @options[:trackfile] || "data/tracks/test_track.json"
        @track = Track.create(spec: @trackfile)
        @last_tile = nil

        if @track.track.data["background"]
          _background = @track.track.data["background"]
          _color = Gosu::Color.rgba(_background["red"], _background["green"], _background["blue"], _background["alpha"])
        else
          _color = Gosu::Color.rgba(100,254,78,144) # Soft, forest green.
        end

        @color = _color
      end

      def self.instance=instance
        @instance = instance
      end
      def self.instance
        @instance
      end

      def draw
        super
        fill(@color)
        Game::Net::GamePlay.instance.players.each do |_car|
          next unless _car.angle
          _car.text.x = _car.x
          _car.text.y = _car.y
          _car.text.draw
          _car.image.draw_rot(_car.x, _car.y, 5, _car.angle)
        end
      end

      def update
        super

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
          push_game_state(Pause.new(last_state: self))
        end
      end
    end
  end
end
