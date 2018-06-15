class Track
  class Editor
    class DecorationEditor < EditorMode
      def setup
        @angle = 0
        @scale = 1
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

        @angle_label = sidebar_label "Angle: #{@angle}"
        @scale_label = sidebar_label "Scale: #{@scale}"

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

      def draw
        super

        if @mouse
          over_decorations.each do |decoration|
            $window.draw_circle(decoration.x, decoration.y, decoration.radius, 9999, decoration.debug_color)
          end
        end
      end

      def update
        super
        return unless @mouse
        @mouse_position[:angle] = @angle
        @mouse_position[:scale] = @scale

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
        @editor.decorations << Decoration.new(image: image, x: x, y: y, z: 0, angle: @angle, scale: @scale)
      end

      def over_decoration?
        _decoration = nil
        mouse_x = $window.mouse_x-@editor.screen_vector.x
        mouse_y = $window.mouse_y-@editor.screen_vector.y
        mouse_radius = 0
        if @mouse
          mouse_radius = ((@mouse.width+@mouse.height)/4)*@scale
        end
        @editor.decorations.each do |decoration|
          distance = Gosu::distance(decoration.x, decoration.y, mouse_x, mouse_y)
          if distance <= decoration.radius+mouse_radius
            _decoration = decoration
            break
          end
        end

        return _decoration
      end

      def over_decorations
        _decorations = []
        mouse_x = $window.mouse_x-@editor.screen_vector.x
        mouse_y = $window.mouse_y-@editor.screen_vector.y
        mouse_radius = 0
        if @mouse
          mouse_radius = ((@mouse.width+@mouse.height)/4)*@scale
        end
        @editor.decorations.each do |decoration|
          distance = Gosu::distance(decoration.x, decoration.y, mouse_x, mouse_y)
          if distance <= decoration.radius+mouse_radius
            _decorations << decoration
          end
        end

        return _decorations
      end

      def button_up(id)
        super

        case id
        when Gosu::KbR
          @angle+=45
          @angle%=360

          @angle_label.text.text = "Angle: #{@angle}"
        when Gosu::MsWheelUp
          @scale+=0.1
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        when Gosu::MsWheelDown
          @scale-=0.1
          @scale = 0.1 if @scale < 0.1
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        when Gosu::MsLeft
          if @mouse && @editor.mouse_in?(@editor.active_area)
            if !over_decoration?
              place(@current_tile_image_path)
            end
          end
        when Gosu::MsMiddle
        when Gosu::MsRight
          if @mouse && @editor.mouse_in?(@editor.active_area)
            if decoration = over_decoration?
              @editor.decorations.delete(decoration)
            end
          end
        end
      end
    end
  end
end