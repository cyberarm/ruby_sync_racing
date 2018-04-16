class Track
  class Editor
    class DecorationEditor < EditorMode
      def setup
        sidebar_label("Decorations")
        sidebar_button("Move")
        sidebar_button("Remove")
        sidebar_button(@editor.image("assets/cars/CAR.png"))
        sidebar_button(@editor.image("assets/cars/sport.png"))
      end
    end
  end
end