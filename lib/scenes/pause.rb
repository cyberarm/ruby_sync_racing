module Game
  class Scene
    class Pause < Menu
      def prepare
        title("Ruby Sync Racing")
        label("Paused", size: 50)

        button("Return to Game") do
          $window.show_cursor = false
          push_game_state(@options[:last_state], setup: false)
        end

        button("Main Menu") do
          push_game_state(MainMenu)
        end
      end

      def draw
        @options[:last_state].draw
        $window.flush
        fill(Gosu::Color.rgba(10,15,20,200))
        super
      end

      def button_up(id)
        super

        case id
        when Gosu::KbEscape
          $window.show_cursor = false
          push_game_state(@options[:last_state], setup: false)
        end
      end
    end
  end
end
