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
        @alpha-=1.5 unless @alpha <= 25
      end

      if @alpha >= 255
        @up = false
        @render = true
      elsif @alpha <= 25
        @up = true
      end

      if holding_any?(:enter, :return)
        push_game_state(MainMenu)
      end
    end
  end
end
