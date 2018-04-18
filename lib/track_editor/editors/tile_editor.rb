class Track
  class Editor
    class TileEditor < EditorMode
      def setup
        @current_tile_image_path = nil

        sidebar_label("Tools")
        sidebar_button("Add Tile") do
          puts "Pressed"
        end
        sidebar_button("Edit Tile") do
          puts "Pressed"
        end
        sidebar_button("Remove Tile") do
          puts "Pressed"
        end
        sidebar_button("Rotate 90") do
          puts "Pressed"
        end
        sidebar_button("Rotate -90") do
          puts "Pressed"
        end

        sidebar_label("Tiles")
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt.png")) do
          @current_tile_image_path = "assets/tracks/general/road/asphalt.png"
          @editor.mouse_image(@editor.image("assets/tracks/general/road/asphalt.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt_bottom.png")) do
          @current_tile_image_path = "assets/tracks/general/road/asphalt_bottom.png"
          @editor.mouse_image(@editor.image("assets/tracks/general/road/asphalt_bottom.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt_left_bottom.png")) do
          @current_tile_image_path = "assets/tracks/general/road/asphalt_left_bottom.png"
          @editor.mouse_image(@editor.image("assets/tracks/general/road/asphalt_left_bottom.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/clay.png")) do
          @editor.mouse_image(@editor.image("assets/tracks/general/road/clay.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/grass.png")) do
          @editor.mouse_image(@editor.image("assets/tracks/general/road/clay.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/sandstone.png")) do
          @editor.mouse_image(@editor.image("assets/tracks/general/road/sandstone.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/water.png")) do
          @editor.mouse_image(@editor.image("assets/tracks/general/road/water.png"))
          @editor.use_mouse_image = true
        end
      end

      def add_tile(type, image_path, x, y, z, angle)
        @editor.tiles << Track::Tile.new(type, image_path, x, y, z, angle)
      end

      def button_up(id)
        super

        case id
        when Gosu::MsLeft
          if @editor.mouse && @editor.mouse_in?(@editor.active_area) && @editor.mouse == @editor.image(@current_tile_image_path)
            add_tile(:asphalt, @current_tile_image_path, @editor.mouse_position[:x], @editor.mouse_position[:y], 0, @editor.mouse_position[:angle])
          end
        end
      end
    end
  end
end