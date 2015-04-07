class Track
  class Editor
    class Window < Chingu::Window
      def initialize(width = 1280, height = 832, fullscreen = false)
        super(width, height, fullscreen)
        self.caption = "Track Editor - Ruby Sync Racing"

        push_game_state(Menu)
      end

      def needs_cursor?
        true
      end
    end
  end
end
