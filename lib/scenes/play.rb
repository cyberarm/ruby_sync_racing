module Game
  class Scene
    class Play < Chingu::GameState
      def setup
        $window.show_cursor = false
        @screen_vector = Vector2D.new(0, 0)

        @car = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile])
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
        $window.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
          super
          @car.draw
        end
        fill(@color)
      end

      def update
        super
        @car.update
        @screen_vector.x, @screen_vector.y = (@car.x - $window.width / 2), (@car.y - $window.height / 2)

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
