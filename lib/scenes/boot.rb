module Game
  class Scene
    class Boot < Chingu::GameState
      def setup
        @up = true
        @render = false
        @alpha = 0

        @text = Game::Text.new("Ruby Sync Racing", x: $window.width/3, y: $window.height/3, size: 60)
        @instructions = Game::Text.new("Press ENTER to continue", x: $window.width/3, y: $window.height/2, size: 30, color: Gosu::Color::GRAY)
      end

      def draw
        super
        @text.draw
        @instructions.draw if @render
        fill(Gosu::Color.rgba(255,255,255,179))
      end

      def update
        super
        @text.alpha = @alpha

        if @up
          @alpha+=1.5 unless @alpha >= 255
        else
          @alpha-=1.5 unless @alpha <= 50
        end

        if @alpha >= 255
          @up = false
          @render = true
        elsif @alpha <= 50
          @up = true
        end
      end

      def button_up(id)
        case id
        when Gosu::KbEscape
          exit
        else
          push_game_state(MainMenu)
        end
      end
    end
  end
end
