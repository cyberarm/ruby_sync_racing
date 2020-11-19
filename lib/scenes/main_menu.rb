module Game
  class Scene
    class MainMenu < Menu
      def prepare
        title "Ruby Sync Racing"
        button "Play" do
          push_state(LevelSelection)
        end

        # button "Play Online" do
        #   push_state(MultiplayerMenu)
        # end

        button "Track Editor", Gosu::Color.rgba(50, 150, 50, 200), Gosu::Color.rgba(100, 150, 100, 200) do
          push_state(Track::Editor::Menu)
        end

        button "Exit", Gosu::Color.rgba(200, 50, 50, 200), Gosu::Color.rgba(200, 100, 100, 200) do
          exit
        end
      end
    end
  end
end
