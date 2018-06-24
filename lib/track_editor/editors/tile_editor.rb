class Track
  class Editor
    class TileEditor < EditorMode
      def setup
        @grid = {}

        @tiles_list = {
          "asphalt": [
            "assets/tracks/general/road/asphalt.png",
            "assets/tracks/general/road/asphalt_left.png",
            "assets/tracks/general/road/asphalt_left_bottom.png"
          ],
          "dirt": [
            "assets/tracks/general/road/clay.png",
            "assets/tracks/general/road/sandstone.png",
            "assets/tracks/general/road/grass.png"
          ],
          "water": [
            "assets/tracks/general/road/water.png"
          ],
          "ice": [

          ]
        }

        sidebar_label "Tools"
        sidebar_button("Jump 0:0", "Press \"0\"") do
          @editor.screen_vector.x = 0
          @editor.screen_vector.y = 0
        end
        sidebar_button("Rotate 90", "Press \"R\"") do
          @mouse_position[:angle]+=90
          @mouse_position[:angle] %= 360
        end
        sidebar_button("Rotate -90") do
          @mouse_position[:angle]-=90
          @mouse_position[:angle] %= 360
        end

        sidebar_label("Tiles")
        @tiles_list.each do |type, list|
          sidebar_label(type.capitalize)
          list.each do |tile|
            sidebar_button(@editor.image(tile), tile.split('/').last.split('.').first.capitalize) do
              @current_tile_image_path = tile
              mouse_image(@editor.image(tile))
              @use_mouse_image = true
            end
          end
        end
      end

      def add_tile(type, image_path, angle)
        x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
        z = 0
        if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::Tile)
          @editor.error_sound.play
        else
          tile = Track::Tile.new(type, image_path, x, y, z, angle)
          @grid["#{x}"] = {} unless @grid["#{x}"].is_a?(Hash)
          @grid["#{x}"]["#{y}"] = tile
          @editor.tiles << tile
        end
      end

      def update
        super
        return unless @mouse
        @mouse_position[:x] = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        @mouse_position[:y] = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
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
                                  tile["image"],
                                  _x,
                                  _y,
                                  _z,
                                  _angle)
          @grid["#{_x}"] = {} unless @grid["#{_x}"].is_a?(Hash)
          @grid["#{_x}"]["#{_y}"] = _tile
          @editor.tiles << _tile
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @mouse && @editor.mouse_in?(@editor.active_area) && @mouse == @editor.image(@current_tile_image_path)
            add_tile(:asphalt, @current_tile_image_path, @mouse_position[:angle])
          end

        when Gosu::MsMiddle
          if @mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
            if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::Tile)
              tile = @grid["#{x}"]["#{y}"]
              @current_tile_image_path = tile.image
              mouse_image(@editor.image(tile.image))
              @use_mouse_image = true
            end
          end

        when Gosu::MsRight
          if @mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
            if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::Tile)
              @editor.tiles.delete(@grid["#{x}"]["#{y}"])
              @grid["#{x}"]["#{y}"] = nil
            end
          end

        when Gosu::Kb0
          @editor.add_message "Screen reset to default position"
          @editor.screen_vector.x=0
          @editor.screen_vector.y=0

        when Gosu::KbR
           @mouse_position[:angle]+=90
           @mouse_position[:angle]%=360
        end
      end
    end
  end
end