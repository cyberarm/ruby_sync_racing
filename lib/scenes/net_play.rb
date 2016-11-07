module Game
  class Scene
    class NetPlay < Chingu::GameState
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
        Game::Net::GamePlay.instance.players.each do |car|
          next unless car.angle
          car.image.draw_rot(car.x, car.y, 5, car.angle)
        end
      end

      def update
        super
        @net_tick+=1

        # if @net_tick > 1
          @client.update(0)
          # @net_tick = 0
        # end

        @client.transmit('game', 'player_moved', {angle: @car.angle, x: @car.x, y: @car.y}, GameOverseer::Client::WORLD, false)

        tile = @track.collision.find(@car.x, @car.y)
        if tile
          @last_tile.color = nil if @last_tile != nil
          @last_tile = tile
          tile.color = Gosu::Color::GRAY
        end
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
