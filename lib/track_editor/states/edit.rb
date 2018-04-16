class Track
  class Editor
    class Edit < EditorContainer
      def prepare
        selector("Tiles", TileEditor.new, Gosu::Color.rgb(50, 50, 150))
        selector("Decorations", DecorationEditor.new, Gosu::Color.rgb(50, 150, 50))
        # selector("Checkpoints", :Decorations, Gosu::Color.rgb(150, 50, 50))
        # selector("Starting Positions", :Decorations, Gosu::Color.rgb(50, 50, 50))
      end
    end
  end
end