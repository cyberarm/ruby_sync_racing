class Scene
  class MainMenu < Chingu::GameState
    def setup
      @title = Chingu::Text.new("Ruby Sync Racing", x: $window.width/3, y: 100, color: Gosu::Color::WHITE, size: 80)

      @play = Chingu::Text.new("Press 'P' to PLAY", x: $window.width/3, y: 200, size: 40)
      @exit = Chingu::Text.new("Press 'Escape' to QUIT", x: $window.width/3, y: 250, size: 40)

      $window.show_cursor = true
    end

    def draw
      super
      @title.draw
      @play.draw
      @exit.draw
      fill(Gosu::Color.rgba(255,255,255,179))
    end

    def update
      push_game_state(Game) if holding_any?(:p)

      exit if holding_any?(:escape)
    end
  end
end
