class Track
  class Editor
    class Window < Chingu::Window
      def initialize
        super(1280,832,false)
        self.caption = "Track Editor - Ruby Sync Racing"

        push_game_state(Menu)
      end

      def needs_cursor?
        true
      end
    end
  end
end
