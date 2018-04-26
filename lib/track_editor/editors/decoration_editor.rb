class Track
  class Editor
    class DecorationEditor < EditorMode
      def setup
        @use_grid_placement = true
        sidebar_label("Decorations")
        sidebar_button("Disable Grid", "Toggle grid placement") do |button|
          if @use_grid_placement # Turning it off
            button.text.text = "Enable Grid"
          else
            button.text.text = "Disable Grid"
          end

          @use_grid_placement = !@use_grid_placement
        end

        sidebar_label("Decorations")
        sidebar_button(@editor.image("assets/cars/CAR.png"), "Car") do
          mouse_image(@editor.image("assets/cars/CAR.png"))
          @current_tile_image_path = "assets/cars/CAR.png"
          @use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/cars/sport.png"), "Sport") do
          mouse_image(@editor.image("assets/cars/sport.png"))
          @current_tile_image_path = "assets/cars/sport.png"
          @use_mouse_image = true
        end

        puts @editor
      end

      def update
        super
        return unless @mouse
        if @use_grid_placement
          @mouse_position[:x] = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
          @mouse_position[:y] = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
        else
          @mouse_position[:x] = $window.mouse_x-@editor.screen_vector.x
          @mouse_position[:y] = $window.mouse_y-@editor.screen_vector.y
        end
      end

      def place(image)
        x = @mouse_position[:x]
        y = @mouse_position[:y]
        @editor.decorations << Decoration.new(image: image, x: x, y: y, z: 5, angle: 0, scale: 25)
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @mouse && @editor.mouse_in?(@editor.active_area)
            place(@current_tile_image_path)
          end
        when Gosu::MsMiddle
        when Gosu::MsRight
        end
      end
    end
  end
end