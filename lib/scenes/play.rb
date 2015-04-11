module Game
  class Scene
    class Play < Chingu::GameState
      def setup
        $window.show_cursor = false

        @car = Car.create(x: $window.width/2, y: $window.height/2, spec: @options[:carfile])
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

      def draw
        super
        fill(@color)
      end

      def update
        super

        tile = @track.collision.find(@car.x, @car.y)
        if tile
          @last_tile.color = nil if @last_tile != nil
          @last_tile = tile
          tile.color = Gosu::Color::GRAY
        end
      end
    end
  end
end
