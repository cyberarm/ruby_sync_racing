class Track
  class Editor
    class Window < Display
      def initialize(width = Gosu.screen_width, height = Gosu.screen_height, fullscreen = true)
        super(width, height, fullscreen)
        self.width,self.height,self.fullscreen = width,height,fullscreen

        self.caption = "Track Editor - Ruby Sync Racing"

        if ARGV.join.include?("--new")
          push_game_state(Edit)
        else
          push_game_state(Menu)
        end
      end

      def needs_cursor?
        true
      end
    end
  end
end
