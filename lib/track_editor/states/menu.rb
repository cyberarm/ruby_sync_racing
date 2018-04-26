class Track
  class Editor
    class Menu < Game::Scene::Menu
      def prepare
        background(Gosu::Color.rgba(100,100,75, 100))
        title "Ruby Sync Racing"
        label "Track Editor", size: 48

        button "Create Track", Gosu::Color.rgba(50, 150, 50, 200), Gosu::Color.rgba(100, 150, 100, 200) do
          push_game_state(Edit)
        end

        button "Load Track", Gosu::Color.rgba(50, 150, 50, 200), Gosu::Color.rgba(100, 150, 100, 200) do
          push_game_state(Load)
        end

        button "Main Menu", Gosu::Color.rgba(50, 150, 50, 200), Gosu::Color.rgba(100, 150, 100, 200) do
          push_game_state(Game::Scene::MainMenu)
        end

        button "Exit", Gosu::Color.rgba(200, 50, 50, 200), Gosu::Color.rgba(200, 100, 100, 200) do
          $window.close
          exit
        end
      end
    end
  end
end
