class Track
  class Editor
    class TileEditor < EditorMode
      def setup
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
          @editor.mouse_image(@editor.image("assets/tracks/general/road/asphalt.png"))
          @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt_bottom.png")) do
          @editor.mouse_image(@editor.image("assets/tracks/general/road/asphalt_bottom.png"))
          # @editor.use_mouse_image = true
        end
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt_left_bottom.png")) do
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
    end
  end
end