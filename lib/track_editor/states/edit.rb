class Track
  class Editor
    class Edit < EditorContainer
      def prepare
        selector("Tiles", :Tiles)
        selector("Decorations", :Decorations)
        selector("Checkpoints", :Decorations)
        selector("Starting Positions", :Decorations)
      end
    end
  end
end