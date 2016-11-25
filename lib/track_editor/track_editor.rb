class Track
  class Editor
    class Window < Chingu::Window
      def initialize(width = Gosu.screen_width, height = Gosu.screen_height, fullscreen = true)
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
