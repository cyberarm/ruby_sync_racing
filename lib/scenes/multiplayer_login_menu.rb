module Game
  class Scene
    class MultiplayerLoginMenu < Menu
      def prepare
        title "Ruby Sync Racing"
        label "Multiplayer Login", size: 50

        label "Enter a Username:"
        username = edit_line Config.get(:player_username)

        button "Login" do
          # Network request for access token
          # Net::Auth.new(username.text.text)
          Game::Net::Client.username = username.text.text
          push_game_state(MultiplayerMenu.new(username: username))
        end
        button "Sign up" do
          push_game_state(MultiplayerSignUpMenu)
        end

        button "Cancel" do
          push_game_state(MainMenu)
        end
      end
    end
  end
end
