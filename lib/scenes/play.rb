module Game
  class Scene
    class Play < GameState
      def setup
        $window.show_cursor = false
        @screen_vector = Vector2D.new(0, 0)

        @trackfile = @options[:trackfile] || "data/tracks/test_track.json"
        @track = Track.new(spec: @trackfile)
        if @track.starting_positions.count > 0
          start_position = @track.starting_positions.first
          @car = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])
        else
          @car = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
        end
        @last_tile = nil

        if @track.track.data["background"]
          _background = @track.track.data["background"]
          _color = Gosu::Color.rgba(_background["red"], _background["green"], _background["blue"], _background["alpha"])
        else
          _color = Gosu::Color.rgba(100,254,78,144) # Soft, forest green.
        end

        @color = _color
        @car.calc_boundry(@track.tiles)
        puts "Car boundry: #{@car.boundry}"

        @car_text = Text.new("", x: 10, y: 10, z: 8181, size: 24, color: Gosu::Color::GREEN)
      end

      def draw
        $window.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
          super
          fill_rect(@car.boundry[0], @car.boundry[1], @car.boundry[2]+@track.tile_size*4, @car.boundry[3]+@track.tile_size*4, Gosu::Color.rgba(255, 0, 0, 150), 100) if $debug
        end
        fill(@color, -1)
        @car_text.draw
      end

      def update
        super
        @screen_vector.x, @screen_vector.y = (@car.x - $window.width / 2), (@car.y - $window.height / 2)

        @car_text.text = "Car x: #{@car.x.round}, y: #{@car.y.round}, angle: #{@car.angle}"

        tile = @track.collision.find(@car.x, @car.y)
        if tile
          @last_tile.color = nil if @last_tile != nil
          @last_tile = tile
          tile.color = Gosu::Color::GRAY
        end
      end

      def button_up(id)
        super
        case id
        when Gosu::KbEscape
          push_game_state(Pause.new(last_state: self))
        end
      end
    end
  end
end
