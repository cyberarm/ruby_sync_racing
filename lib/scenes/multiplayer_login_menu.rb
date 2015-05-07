module Game
  class Scene
    class MultiplayerLoginMenu < Menu
      def prepare
        title "Ruby Sync Racing"
        label "Multiplayer Login", size: 50

        label "Username:"
        username = edit_line "cyberarm"
        label "Password:"
        password = edit_line "", secret: true

        button "Login" do
          # Network request for access token
          # Net::Auth.new(username.text, password.text)
          push_game_state(MultiplayerMenu.new(username: username, password: password))
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
