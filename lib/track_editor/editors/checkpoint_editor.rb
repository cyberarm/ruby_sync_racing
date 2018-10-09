class Track
  class Editor
    class CheckPointEditor < EditorMode
      def setup
        @boxes = []

        @mouse = @editor.checkpoint_tile
        @mouse_from_gosu_record = true

        @color = Gosu::Color.rgba(255, 255, 64, 150)
        @active_checkpoint = nil

        @position = sidebar_label "<_>"
      end

      def add_checkpoint(x, y, width, height)
        checkpoint = Track::CheckPoint.new(x, y, width, height)
        @editor.checkpoints << checkpoint
        @active_checkpoint = nil

        @editor.track_changed!
      end

      def remove_checkpoint
        x = ($window.mouse_x - @editor.screen_vector.x)
        y = ($window.mouse_y - @editor.screen_vector.y)

        @position.text.text = "#{x}:#{y}"
        @sidebar.calculate_widest_element

        @editor.checkpoints.each do |checkpoint|
          if x.between?(checkpoint.x, checkpoint.x+checkpoint.width)

            if y.between?(checkpoint.y, checkpoint.y+checkpoint.height)
              @editor.checkpoints.delete(checkpoint)

              @editor.track_changed!
            end
          end
        end
      end

      def load_track(track_data)
        track_data["checkpoints"].each do |checkpoint|
          @editor.checkpoints << Track::CheckPoint.new(checkpoint["x"], checkpoint["y"], checkpoint["width"], checkpoint["height"])
        end
      end

      def draw
        super

        Gosu.clip_to(@editor.active_area.x, @editor.active_area.y, @editor.active_area.width, @editor.active_area.height) do
          Gosu.translate(@editor.screen_vector.x, @editor.screen_vector.y) do
            if @active_checkpoint
              Gosu.draw_rect(
                @active_checkpoint.x,
                @active_checkpoint.y,
                @active_checkpoint.width,
                @active_checkpoint.height,
                @color,
                Float::INFINITY
              )
            end

            @editor.checkpoints.each do |checkpoint|
              x = ($window.mouse_x - @editor.screen_vector.x)
              y = ($window.mouse_y - @editor.screen_vector.y)

              if x.between?(checkpoint.x, checkpoint.x+checkpoint.width)
                if y.between?(checkpoint.y, checkpoint.y+checkpoint.height)
                  Gosu.draw_rect(
                    checkpoint.x,
                    checkpoint.y,
                    checkpoint.width,
                    checkpoint.height,
                    @color,
                    Float::INFINITY
                  )
                end
              end
            end
          end
        end
      end

      def update
        super

        @x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        @y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2

        @mouse_position[:x] = @x
        @mouse_position[:y] = @y

        if $window.button_down?(Gosu::MsLeft)
          @active_checkpoint ||= CheckPoint.new(@x, @y, 0, 0)

          @active_checkpoint.width = (@active_checkpoint.x - @x)*-1
          @active_checkpoint.height= (@active_checkpoint.y - @y)*-1
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @active_checkpoint
            if @active_checkpoint.x + @active_checkpoint.width < @active_checkpoint.x
              x = @active_checkpoint.x
              @active_checkpoint.x = x + @active_checkpoint.width
              @active_checkpoint.width = @active_checkpoint.width.abs
            end

            if @active_checkpoint.y + @active_checkpoint.height < @active_checkpoint.y
              y = @active_checkpoint.y
              @active_checkpoint.y = y + @active_checkpoint.height
              @active_checkpoint.height = @active_checkpoint.height.abs
            end

            if @active_checkpoint.width < @editor.tile_size || @active_checkpoint.height < @editor.tile_size
              @active_checkpoint = nil
              return
            end

            add_checkpoint(@active_checkpoint.x, @active_checkpoint.y, @active_checkpoint.width, @active_checkpoint.height)
          end
        when Gosu::MsRight
          remove_checkpoint
        end
      end
    end
  end
end