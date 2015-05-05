module Game
  class Scene
    class MainMenu < Menu
      def prepare
        title "Ruby Sync Racing"
        button "Play" do
          push_game_state(LevelSelection)
        end

        button "Exit" do
          exit
        end
      end
    end
  end
end
