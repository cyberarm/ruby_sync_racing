class Track
  class Editor
    class TileEditor < EditorMode
      def setup
        @current_tile_image_path = nil
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
          @editor.mouse_position[:angle]+=90
          @editor.mouse_position[:angle] %= 360
        end
        sidebar_button("Rotate -90") do
          @editor.mouse_position[:angle]-=90
          @editor.mouse_position[:angle] %= 360
        end

        sidebar_label("Tiles")
        @tiles_list.each do |type, list|
          sidebar_label(type.capitalize)
          list.each do |tile|
            sidebar_button(@editor.image(tile), tile.split('/').last.split('.').first.capitalize) do
              @current_tile_image_path = tile
              @editor.mouse_image(@editor.image(tile))
              @editor.use_mouse_image = true
            end
          end
        end
      end

      def add_tile(type, image_path, angle)
        x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@editor.mouse.width/2
        y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@editor.mouse.height/2
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
        return unless @editor.mouse
        @editor.mouse_position[:x], @editor.mouse_position[:y] =@editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@editor.mouse.width/2,
                                                                @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@editor.mouse.height/2
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @editor.mouse && @editor.mouse_in?(@editor.active_area) && @editor.mouse == @editor.image(@current_tile_image_path)
            add_tile(:asphalt, @current_tile_image_path, @editor.mouse_position[:angle])
          end

        when Gosu::MsMiddle
          if @editor.mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@editor.mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@editor.mouse.height/2
            if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::Tile)
              tile = @grid["#{x}"]["#{y}"]
              @current_tile_image_path = tile.image
              @editor.mouse_image(@editor.image(tile.image))
              @editor.use_mouse_image = true
            end
          end

        when Gosu::MsRight
          if @editor.mouse && @editor.mouse_in?(@editor.active_area)
            x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@editor.mouse.width/2
            y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@editor.mouse.height/2
            if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::Tile)
              @editor.tiles.delete(@grid["#{x}"]["#{y}"])
              @grid["#{x}"]["#{y}"] = nil
            end
          end

        when Gosu::Kb0
          # @editor.add_message "Screen reset to default position"
          @editor.screen_vector.x=0
          @editor.screen_vector.y=0

        when Gosu::KbR
           @editor.mouse_position[:angle]+=90
           @editor.mouse_position[:angle]%=360
        end
      end
    end
  end
end