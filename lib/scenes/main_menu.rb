class Scene
  class MainMenu < Chingu::GameState
    def setup
      @title = Chingu::Text.new("Ruby Sync Racing", x: $window.width/3, y: 100, color: Gosu::Color::WHITE, size: 80)

      @play = Chingu::Text.new("Play", x: $window.width/3, y: 200, size: 40)
      @exit = Chingu::Text.new("Exit", x: $window.width/3, y: 280, size: 40)

      $window.show_cursor = true
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

    def update

      exit if holding_any?(:escape)
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        # Play Button
        if $window.mouse_x.between?(@play.x-10, @play.x+@play.width+20)
          if $window.mouse_y.between?(@play.y-5, @play.y+@play.height+10)
            push_game_state(Game)
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
