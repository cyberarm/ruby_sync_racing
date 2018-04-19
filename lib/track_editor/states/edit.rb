class Track
  class Editor
    class Edit < EditorContainer
      def prepare
        selector("File", FileEditor, Gosu::Color.rgb(50, 50, 50))
        selector("Tiles", TileEditor, Gosu::Color.rgb(50, 50, 150))
        selector("Decorations", DecorationEditor, Gosu::Color.rgb(50, 150, 50))
        # selector("Checkpoints", :Decorations, Gosu::Color.rgb(150, 50, 50))
        # selector("Starting Positions", :Decorations, Gosu::Color.rgb(50, 50, 50))
      end
    end
  end
end