class Scene
  class MainMenu < Chingu::GameState
    def setup
      @title = Game::Text.new("Ruby Sync Racing", x: $window.width/2, y: 100, color: Gosu::Color::WHITE, size: 80)

      @play = Game::Text.new("Play", x: $window.width/3, y: 200, size: 40)
      @exit = Game::Text.new("Exit", x: $window.width/3, y: 280, size: 40)

      $window.show_cursor = true

      # Position all the things.
      @title.x = $window.width/2-@title.width/2
      @play.x  = $window.width/2-@play.width/2
      @exit.x  = $window.width/2-@exit.width/2
    end

    def draw
      super
      fill(Gosu::Color.rgba(255,255,255,179), -5)
      @title.draw
      @play.draw
      @exit.draw

      fill_rect([@play.x-10, @play.y-5, @play.width+20, @play.height+10], Gosu::Color::BLACK, -1)
      fill_rect([@exit.x-10, @exit.y-5, @exit.width+20, @exit.height+10], Gosu::Color::BLACK, -1)
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        # Play Button
        if $window.mouse_x.between?(@play.x-10, @play.x+@play.width+20)
          if $window.mouse_y.between?(@play.y-5, @play.y+@play.height+10)
            push_game_state(LevelSelection)
          end
        end

        # Quit Button
        if $window.mouse_x.between?(@exit.x-10, @exit.x+@exit.width+20)
          if $window.mouse_y.between?(@exit.y-5, @exit.y+@exit.height+10)
            $window.close
            exit
          end
        end
      end
    end
  end
end
