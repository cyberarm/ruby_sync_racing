class Track
  class Editor
    class TileEditor < EditorMode
      def setup
        sidebar_label("HELLO WORLD")
        sidebar_button("Hello")
        sidebar_button(@editor.image("assets/tracks/general/road/asphalt.png"))
      end
    end
  end
end