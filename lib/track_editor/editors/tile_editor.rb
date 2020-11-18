class Track
  class Editor
    class TileEditor < EditorMode
      def setup
        @grid = {}
        @painting = false
        @left_mouse_down_at = Gosu.milliseconds
        @left_mouse_down_paint = 150

        @tile_lock = true

        @tiles_list = {
          "asphalt": [
            AssetManager.image_from_id(100),
            AssetManager.image_from_id(101),
            AssetManager.image_from_id(102),
            AssetManager.image_from_id(103),
            AssetManager.image_from_id(105),
            AssetManager.image_from_id(104),
            AssetManager.image_from_id(106),
            AssetManager.image_from_id(107),
            AssetManager.image_from_id(108),
            AssetManager.image_from_id(109),
            AssetManager.image_from_id(110),
          ],
          "dirt": [
            AssetManager.image_from_id(115),
            AssetManager.image_from_id(120),
            AssetManager.image_from_id(121),
            AssetManager.image_from_id(122),
            AssetManager.image_from_id(123),
            AssetManager.image_from_id(124),

            AssetManager.image_from_id(116),
            AssetManager.image_from_id(125),
            AssetManager.image_from_id(126),
            AssetManager.image_from_id(127),
            AssetManager.image_from_id(128),
            AssetManager.image_from_id(129),

            AssetManager.image_from_id(117),
            AssetManager.image_from_id(130),
            AssetManager.image_from_id(131),
            AssetManager.image_from_id(132),
            AssetManager.image_from_id(133),
            AssetManager.image_from_id(134),

            AssetManager.image_from_id(119),
            AssetManager.image_from_id(135),
            AssetManager.image_from_id(136),
            AssetManager.image_from_id(137),
            AssetManager.image_from_id(138),
            AssetManager.image_from_id(139),
          ],
          "water": [
            AssetManager.image_from_id(118),
            AssetManager.image_from_id(140),
          ],
          "ice": [

          ]
        }

        sidebar_label "Tools"
        sidebar_button("Jump 0:0", "Press \"0\"") do
          @editor.button_up(Gosu::Kb0)
        end
        sidebar_button("Rotate 90", "Press \"R\"") do
          @mouse_position[:angle]+=90
          @mouse_position[:angle] %= 360
        end
        sidebar_button("Rotate -90") do
          @mouse_position[:angle]-=90
          @mouse_position[:angle] %= 360
        end
        sidebar_button("Disable Tile Lock", "Toggles tile overwrite protection") do |button|
          @tile_lock = !@tile_lock

          button.text.text = @tile_lock ? "Disable Tile Lock" : "Enable Tile Lock"
        end

        sidebar_label("Tiles")
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

      def add_tile(type, image_path, angle)
        x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
        z = 0
        if @grid.dig(x, y).is_a?(Track::Tile) && @tile_lock
          tile_name = File.basename(@grid[x][y].image, ".png").split("_").map { |t| t.capitalize }.join(" ")
          @editor.add_message("Tile \"#{tile_name}\" is already placed there.") unless @painting
          @editor.error_sound.play unless @painting
        else
          tile = Track::Tile.new(type, image_path, x, y, z, angle)
          @grid[x] = {} unless @grid[x].is_a?(Hash)
          @grid[x][y] = tile
          @editor.tiles << tile

          @editor.track_changed!
        end
      end

      def update
        super
        return unless @mouse
        @mouse_position[:x] = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        @mouse_position[:y] = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2

        if $window.button_down?(Gosu::MsLeft) or $window.button_down?(Gosu::MsRight)
          @painting = Gosu.milliseconds-@left_mouse_down_at >= @left_mouse_down_paint
          if @painting
            if @mouse && @editor.mouse_in?(@editor.active_area) && @mouse == @editor.get_image(@current_tile_image_path) && $window.button_down?(Gosu::MsLeft)
              add_tile(@current_tile_type, @current_tile_image_path, @mouse_position[:angle])

              @editor.track_changed!
            end

            if @mouse && @editor.mouse_in?(@editor.active_area) && $window.button_down?(Gosu::MsRight)
              x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
              y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
              if @grid.dig(x, y).is_a?(Track::Tile)
                @editor.tiles.delete(@grid.dig(x, y))
                @grid[x][y] = nil

                @editor.track_changed!
              end
            end
          end
        else
          @left_mouse_down_at = Gosu.milliseconds
        end
      end

      def load_track(track_data)
        track_data["tiles"].each do |tile|
          _x = tile["x"]
          _y = tile["y"]
          _z = tile["z"]
          _angle = tile["angle"]
          # Correct for old maps that don't have z and angle stored.
          _z     ||= 0
          _angle ||= 0

          _tile = Track::Tile.new(tile["type"],
                                  AssetManager.image_from_id(tile["image"]),
                                  _x,
                                  _y,
                                  _z,
                                  _angle)
          @grid[_x] = {} unless @grid[_x].is_a?(Hash)
          @grid[_x][_y] = _tile
          @editor.tiles << _tile
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @mouse && @editor.mouse_in?(@editor.active_area) && @mouse == @editor.get_image(@current_tile_image_path)
            add_tile(@current_tile_type, @current_tile_image_path, @mouse_position[:angle])
          end

        when Gosu::MsMiddle
          if @mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
            if tile = @grid.dig(x, y) && tile.is_a?(Track::Tile)
              @current_tile_image_path = tile.image
              mouse_image(@editor.get_image(tile.image))
              @use_mouse_image = true
            end
          end

        when Gosu::MsRight
          if @mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
            if @grid.dig(x, y).is_a?(Track::Tile)
              @editor.tiles.delete(@grid[x][y])
              @grid[x][y] = nil

              @editor.track_changed!
            end
          end

        when Gosu::KbR
           @mouse_position[:angle]+=90
           @mouse_position[:angle]%=360
        end
      end
    end
  end
end