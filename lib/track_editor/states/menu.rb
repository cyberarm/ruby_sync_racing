class Track
  class Editor
    class Menu < GameState
      def setup
        @title      = Game::Text.new("Track Editor", size: 50, y: 100)
        @sub_title  = Game::Text.new("Ruby Sync Racing", size: 40, y: 150)
        @new_track  = Game::Text.new("New Track", size: 23, y: 220, z: 2)
        @load_track = Game::Text.new("Load Track", size: 23, y: 320, z: 2)
        @quit       = Game::Text.new("Quit", size: 23, y: 420, z: 2)
      end

      def draw
        super
        @title.draw
        @sub_title.draw
        @new_track.draw
        @load_track.draw
        @quit.draw

        $window.fill_rect(@new_track.x-20, @new_track.y-20, @new_track.width+40, @new_track.height+40, Gosu::Color::GRAY, 1)
        $window.fill_rect(@load_track.x-20, @load_track.y-20, @load_track.width+40, @load_track.height+40, Gosu::Color::GRAY, 1)
        $window.fill_rect(@quit.x-20, @quit.y-20, @quit.width+40, @quit.height+40, Gosu::Color::GRAY, 1)
      end

      def update
        @title.x      = ($window.width/2)-(@title.width/2)
        @sub_title.x  = ($window.width/2)-(@sub_title.width/2)
        @new_track.x  = ($window.width/2)-(@new_track.width/2)
        @load_track.x = ($window.width/2)-(@load_track.width/2)
        @quit.x       = ($window.width/2)-(@quit.width/2)
      end

      def button_up(id)
        case id
        when Gosu::MsLeft
          # New track button
          if $window.mouse_x.between?(@new_track.x-20, @new_track.x+@new_track.width+40)
            if $window.mouse_y.between?(@new_track.y-20, @new_track.y+@new_track.height+40)
              push_game_state(Edit)
            end
          end

          # Load track button
          if $window.mouse_x.between?(@load_track.x-20, @load_track.x+@load_track.width+40)
            if $window.mouse_y.between?(@load_track.y-20, @load_track.y+@load_track.height+40)
              push_game_state(Load)
            end
          end

          # Quit button
          if $window.mouse_x.between?(@quit.x-20, @quit.x+@quit.width+40)
            if $window.mouse_y.between?(@quit.y-20, @quit.y+@quit.height+40)
              exit
            end
          end
        end
      end
    end
  end
end
