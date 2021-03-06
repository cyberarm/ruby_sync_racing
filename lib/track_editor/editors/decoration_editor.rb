class Track
  class Editor
    class DecorationEditor < EditorMode
      def setup
        @angle = 0
        @scale = 1
        @rotate_step = 15
        @scale_step  = 0.1
        @collidable = false
        @use_grid_placement = true

        @tiles_list = {
          "track": [
            AssetManager.image_from_id(141),
          ]
        }

        sidebar_label("Tools")
        sidebar_button("Jump 0:0", "Press \"0\"") do
          @editor.button_up(Gosu::Kb0)
        end
        @grid_toggle = sidebar_button("Disable Grid", "Toggle grid placement. Press \"T\"") do |button|
          if @use_grid_placement # Turning it off
            button.text.text = "Enable Grid"
          else
            button.text.text = "Disable Grid"
          end

          @use_grid_placement = !@use_grid_placement
        end

        @angle_label = sidebar_label "Angle: #{@angle}"
        @scale_label = sidebar_label "Scale: #{@scale}"

        sidebar_button("Rotate #{@rotate_step}d", "Press \"R\"") do
          @angle+=@rotate_step
          @angle%=360
          @angle_label.text.text = "Angle: #{@angle}"
        end
        sidebar_button("Rotate -#{@rotate_step}d", "Press \"Shift+R\"") do
          @angle-=@rotate_step
          @angle%=360
          @angle_label.text.text = "Angle: #{@angle}"
        end

        sidebar_button("Scale #{@scale_step}", "\"Scroll+Up\"") do
          @scale+=@scale_step
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        end
        sidebar_button("Scale -#{@scale_step}", "\"Scroll+Down\"") do
          @scale-=@scale_step
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        end

        sidebar_label("Decorations")
        @tiles_list.each do |type, list|
          sidebar_label(type.capitalize)
          list.each do |tile|
            sidebar_button(@editor.get_image(tile), tile.split('/').last.split('.').first.capitalize) do
              @current_tile_image_path = tile
              @current_tile_type = type
              mouse_image(@editor.get_image(tile))
              @use_mouse_image = true
            end
          end
        end
      end

      def draw
        super

        if @mouse
          Gosu.clip_to(@editor.active_area.x, @editor.active_area.y, @editor.active_area.width, @editor.active_area.height) do
            Gosu.translate(@editor.screen_vector.x, @editor.screen_vector.y) do
              over_decorations.each do |decoration|
                $window.draw_circle(decoration.x, decoration.y, decoration.radius, 9999, Gosu::Color.rgb(255,144,0))
              end
              # Render current decorations radius
              radius = ((@editor.get_image(@current_tile_image_path).width+@editor.get_image(@current_tile_image_path).height)/4)*@scale
              $window.draw_circle(@mouse_position[:x], @mouse_position[:y], radius, 9999, Gosu::Color.rgb(255,144,0))
            end
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

      def load_track(track_data)
        track_data["decorations"].each do |decoration|
          _collidable = decoration["collidable"]
          _image_path = AssetManager.image_from_id(decoration["image"])
          _x = decoration["x"]
          _y = decoration["y"]
          _z = decoration["z"]
          _angle = decoration["angle"]
          _scale = decoration["scale"]

        _radius = ((@editor.get_image(_image_path).width+@editor.get_image(_image_path).height)/4)*@scale

          @editor.decorations << Track::Decoration.new(_collidable, _image_path, _x, _y, _z, _angle, _scale, _radius)
        end
      end

      def place(image)
        x, y = 0, 0

        if @use_grid_placement
          x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
          y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
        else
          x = $window.mouse_x-@editor.screen_vector.x
          y = $window.mouse_y-@editor.screen_vector.y
        end
        radius = ((@editor.get_image(@current_tile_image_path).width+@editor.get_image(@current_tile_image_path).height)/4)*@scale

        @editor.decorations << Decoration.new(@collidable, @current_tile_image_path, x, y, 0, @angle, @scale, radius)
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
          if $window.button_down?(Gosu::KbLeftShift) || $window.button_down?(Gosu::KbRightShift)
            @angle-=@rotate_step
          else
            @angle+=@rotate_step
          end
          @angle%=360

          @angle_label.text.text = "Angle: #{@angle}"
        when Gosu::KbT
          if @use_grid_placement # Turning it off
            @grid_toggle.text.text = "Enable Grid"
          else
            @grid_toggle.text.text = "Disable Grid"
          end

          @use_grid_placement = !@use_grid_placement
        when Gosu::MsWheelUp
          @scale+=@scale_step
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        when Gosu::MsWheelDown
          @scale-=@scale_step
          @scale = @scale_step if @scale < @scale_step
          @scale = @scale.round(2)
          @scale_label.text.text = "Scale: #{@scale}"
        when Gosu::MsLeft
          if @mouse && @editor.mouse_in?(@editor.active_area)
            if !over_decoration?
              place(@current_tile_image_path)
              @editor.track_changed!
            end
          end
        when Gosu::MsMiddle
        when Gosu::MsRight
          if @mouse && @editor.mouse_in?(@editor.active_area)
            if decoration = over_decoration?
              @editor.decorations.delete(decoration)
              @editor.track_changed!
            end
          end
        end
      end
    end
  end
end