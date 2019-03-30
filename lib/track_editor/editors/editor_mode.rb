class Track
  class Editor
    class EditorMode

      attr_reader :sidebar, :editor
      def initialize
        @editor = EditorContainer.instance
        @sidebar = Sidebar.new(self)


        @current_tile_image_path = nil

        @use_mouse_image = true
        @mouse = nil
        @mouse_from_gosu_record = false
        @mouse_position = {x: 0, y: 0, angle: 0, scale: 1}

        setup if defined?(setup)
      end

      def draw
        @sidebar.draw
        Gosu.clip_to(@editor.active_area.x, @editor.active_area.y, @editor.active_area.width, @editor.active_area.height) do
          Gosu.translate(@editor.screen_vector.x, @editor.screen_vector.y) do
            if @mouse_from_gosu_record
              @mouse.draw_rot(@mouse_position[:x], @mouse_position[:y], 50, @mouse_position[:angle], 0.5, 0.5, @mouse_position[:scale], @mouse_position[:scale]) if @mouse  && @use_mouse_image
            else
              @mouse.draw_rot(@mouse_position[:x], @mouse_position[:y], 50, @mouse_position[:angle], 0.5, 0.5, @mouse_position[:scale], @mouse_position[:scale], Gosu::Color.rgba(255,255,255, 150)) if @mouse  && @use_mouse_image
            end

            if @use_mouse_image && @mouse
              mouse_image_bounding_box
            end

            if $debug
              x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@editor.tile_size/2#+@mouse.width/2
              y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@editor.tile_size/2#+@mouse.height/2

              x-=@editor.tile_size if x < 0
              y-=@editor.tile_size if y < 0

              Gosu.draw_rect(x-1, y-1, 3, 3, Gosu::Color::RED, Float::INFINITY) # Shows the tile placement mid-point as a red dot
            end
          end
        end
      end

      def update
        @sidebar.update
      end

      # CALLED WHEN TAB IS SELECTED
      def focused
      end

      def load_track(track_data)
      end

      def mouse_image(image)
        @mouse = image
      end

      def mouse_image_bounding_box
        width = @mouse.width *  @mouse_position[:scale]
        height= @mouse.height * @mouse_position[:scale]
        x = @mouse_position[:x] - width / 2
        y = @mouse_position[:y] - height/ 2
        color = Gosu::Color.rgba(127, 127, 0, 200)

        # TOP LEFT to BOTTOM LEFT
        $window.draw_line(
          x, y, color,
          x, y+height, color,
          Float::INFINITY
        )
        # BOTTOM LEFT to BOTTOM RIGHT
        $window.draw_line(
          x, y+height, color,
          x+width, y+height, color,
          Float::INFINITY
        )
        # BOTTOM RIGHT to TOP RIGHT
        $window.draw_line(
          x+width, y+height, color,
          x+width, y, color,
          Float::INFINITY
        )
        # TOP RIGHT to TOP LEFT
        $window.draw_line(
          x+width, y, color,
          x, y, color,
          Float::INFINITY
        )
      end

      def button_up(id)
        @sidebar.button_up(id)
      end

      def sidebar_button(text_or_image, tooltip = nil, &block)
        button = @sidebar.add_button(text_or_image, tooltip, block)
        return button
      end

      def sidebar_label(text)
        label = @sidebar.add_label(text)
        return label
      end

      def properties
      end
    end
  end
end