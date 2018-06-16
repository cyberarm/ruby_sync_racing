class Track
  class Editor
    class StartingPositionsEditor < EditorMode
      StartingPosition = Struct.new(:x, :y, :angle)
      def setup
        # sidebar_label "Options"
        @angle = 0
        @positions = []
        @font = Gosu::Font.new(24, name: Gosu.default_font_name)

        sidebar_button "Rotate" do
          @angle+=45
          @angle%=360
        end
      end

      def draw
        Gosu.clip_to(@editor.active_area.x, @editor.active_area.y, @editor.active_area.width, @editor.active_area.height) do
          @positions.each_with_index do |position, i|
            Gosu.rotate(position.angle, position.x, position.y) do
              Gosu.draw_rect(position.x-(@editor.tile_size/2), position.y-(@editor.tile_size/2), @editor.tile_size, @editor.tile_size, Gosu::Color.rgba(100,100,100,225), 3)
              Gosu.draw_triangle(
                position.x-(@editor.tile_size/2), position.y, Gosu::Color.rgb(100,50,50),
                position.x, position.y-(@editor.tile_size/2), Gosu::Color.rgb(100,50,50),
                position.x+(@editor.tile_size/2), position.y, Gosu::Color.rgb(100,50,50), 3
                )
              Gosu.draw_rect(position.x-(@editor.tile_size/4), position.y, @editor.tile_size/2, @editor.tile_size/2, Gosu::Color.rgb(100,50,50), 3)
            end
            @font.draw("#{i}", position.x-(@font.text_width("#{i}")/2), position.y, 3)
          end
        end
        super
      end

      def update
        super

        @mouse_position[:x] = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+(@editor.tile_size/2)
        @mouse_position[:y] = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+(@editor.tile_size/2)
      end

      def button_up(id)
        super

        case id
        when Gosu::KbR
          @angle+=45
          @angle%=360
        when Gosu::MsLeft
          unless over_position?
            place_starting_position
          end
        when Gosu::MsRight
          if position = over_position?
            @positions.delete(position)
          end
        end
      end

      def over_position?
        _position = nil
        @positions.each do |position|
          if @mouse_position[:x].between?(position.x-(@editor.tile_size/2), position.x+(@editor.tile_size/2))
            if @mouse_position[:y].between?(position.y-(@editor.tile_size/2), position.y+(@editor.tile_size/2))
              _position = position
              break
            end
          end
        end
        return _position
      end

      def place_starting_position
        if @editor.mouse_in?(@editor.active_area)
          @positions << StartingPosition.new(@mouse_position[:x], @mouse_position[:y], @angle)
        end
      end
    end
  end
end