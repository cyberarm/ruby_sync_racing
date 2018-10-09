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

        @laps = 3
        @completed_laps = 0

        @checkpoints = @track.checkpoints.size
        @checkpoints_list = []
      end

      def draw
        $window.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
          super
          # fill_rect(@car.boundry[0], @car.boundry[1], @car.boundry[2]+@track.tile_size*4, @car.boundry[3]+@track.tile_size*4, Gosu::Color.rgba(255, 0, 0, 150), 100) if $debug
        end
        fill(@color, -1)
        @car_text.draw
      end

      def update
        super
        @screen_vector.x, @screen_vector.y = (@car.x - $window.width / 2), (@car.y - $window.height / 2)

        @car_text.text = "Car speed: #{@car.speed.round} x: #{@car.x.round}, y: #{@car.y.round}, angle: #{@car.angle.round}.\nLaps: #{@completed_laps}/#{@laps}, Checkpoints: #{@checkpoints_list.size}/#{@track.checkpoints.size}"

        tile = @track.collision.find(@car.x, @car.y)
        if tile
          @last_tile.color = nil if @last_tile != nil
          @last_tile = tile
          tile.color = Gosu::Color::GRAY
        end

        lap_check
      end

      def lap_check
        rejectable = nil
        ((@track.checkpoints)-@checkpoints_list).each do |checkpoint|
          if @car.x.between?(checkpoint.x, checkpoint.x+checkpoint.width)
            if @car.y.between?(checkpoint.y, checkpoint.y+checkpoint.height)
              # puts "CHECKPOINT: #{checkpoint}"
              rejectable = checkpoint
              @checkpoints_list << checkpoint unless checkpoint == @lap_rejectable
            end
          end
        end

        @lap_rejectable = nil if rejectable != @lap_rejectable

        if @track.checkpoints.size == @checkpoints_list.size
          @completed_laps+=1
          @checkpoints_list.clear
          @lap_rejectable = rejectable
        end

        if @completed_laps == @laps
          push_game_state(MainMenu)
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
