module Game
  class Scene
    class Pause < Menu
      def prepare
        @last_state = @options[:last_state]
        title("Ruby Sync Racing")
        label("Paused", size: 50)
        button("Main Menu") do
          push_game_state(MainMenu)
        end
      end

      def draw
        @last_state.draw
        $window.flush
        super
        fill(Gosu::Color.rgba(10,15,20,200))
      end

      def button_up(id)
        super

        case id
        when Gosu::KbEscape
          $window.show_cursor = false
          push_game_state(@last_state, setup: false)
        when Gosu::KbM
          push_game_state(MainMenu)
        end
      end
    end
  end
end
