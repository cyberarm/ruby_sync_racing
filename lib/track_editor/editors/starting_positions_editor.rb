class Track
  class Editor
    class StartingPositionsEditor < EditorMode
      def setup
        # sidebar_label "Options"

        sidebar_button("Jump 0:0", "Press \"0\"") do
          @editor.screen_vector.x = 0
          @editor.screen_vector.y = 0
        end
        sidebar_button("Rotate", "Press \"R\"") do
          @angle+=45
          @angle%=360
          @mouse_position[:angle] = @angle
        end

        @angle = 0

        @mouse = @editor.starting_position_tile
        @mouse_from_gosu_record = true
      end

      def load_track(track_data)
        track_data["starting_positions"].each do |tile|
          _x = tile["x"]
          _y = tile["y"]
          _angle = tile["angle"]

          @editor.starting_positions << Track::StartingPosition.new(_x, _y, _angle)
        end
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
          @mouse_position[:angle] = @angle
        when Gosu::MsLeft
          unless over_position?
            place_starting_position
          end
        when Gosu::MsRight
          if position = over_position?
            @editor.starting_positions.delete(position)
          end
        end
      end

      def over_position?
        _position = nil
        @editor.starting_positions.each do |position|
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
          @editor.starting_positions << Track::StartingPosition.new(@mouse_position[:x], @mouse_position[:y], @angle)
        end
      end
    end
  end
end