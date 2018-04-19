class Track
  class Editor
    class Menu < Game::Scene::Menu
      def prepare
        title "Ruby Sync Racing"
        label "Track Editor", size: 48

        button "Create Track" do
          push_game_state(Edit)
        end

        button "Load Track" do
          push_game_state(Load)
        end

        button "Main Menu" do
          push_game_state(Game::Scene::MainMenu)
        end

        button "Exit" do
          $window.close
          exit
        end
      end
    end
  end
end
