module Game
  class Scene
    class MainMenu < Menu
      def prepare
        title "Ruby Sync Racing"
        button "Play" do
          push_game_state(LevelSelection)
        end

        button "Play Online" do
          push_game_state(MultiplayerMenu)
        end

        button "Track Editor" do
          push_game_state(Track::Editor::Menu)
        end

        button "Exit", Gosu::Color.rgba(200, 50, 50, 200), Gosu::Color.rgba(200, 100, 100, 200) do
          exit
        end
      end
    end
  end
end
