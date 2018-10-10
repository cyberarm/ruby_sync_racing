module Game
  class Scene
    class Boot < GameState
      def setup
        @up = true
        @render = false
        @alpha = 0

        @text = Game::Text.new("Ruby Sync Racing", y: $window.height/3, size: 100)
        @text.x = ($window.width/2)-@text.width/2
        @instructions = Game::Text.new("Press ANY KEY to continue", y: $window.height/2, size: 30, color: Gosu::Color::GRAY)
        @instructions.x = ($window.width/2)-@instructions.width/2
      end

      def draw
        super
        @text.draw
        @instructions.draw if @render
        fill(Gosu::Color.rgba(50,50,50,179))
      end

      def update
        super
        @text.alpha = @alpha
        @instructions.alpha = @alpha

        if @up
          @alpha+=1.5 unless @alpha >= 255
        else
          @alpha-=1.5 unless @alpha <= 10
        end

        if @alpha >= 255
          @up = false
          @render = true
        elsif @alpha <= 10
          @text.color = Gosu::Color.rgba(rand(100..255), rand(100..255), rand(100..255), @alpha)
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
