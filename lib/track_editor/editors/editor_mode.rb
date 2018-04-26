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
        @mouse_position = {x: 0, y: 0, angle: 0}

        setup if defined?(setup)
      end

      def draw
        @sidebar.draw
        Gosu.clip_to(@editor.active_area.x, @editor.active_area.y, @editor.active_area.width, @editor.active_area.height) do
          Gosu.translate(@editor.screen_vector.x, @editor.screen_vector.y) do
            @mouse.draw_rot(@mouse_position[:x], @mouse_position[:y], 50, @mouse_position[:angle], 0.5, 0.5, 1.0, 1.0, Gosu::Color.rgba(255,255,255, 150)) if @mouse  && @use_mouse_image
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