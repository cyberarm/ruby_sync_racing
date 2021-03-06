module Game
  module Net
    class Auth < GameOverseer::Client::Service
      def setup
        register_channel("auth")
        @token = nil
      end

      def process_data(data, channel)
        case data['mode']
        when 'connect'
          case data['data']['status']
          when 200
            Game::Net::Client.id = data['data']['client_id']
            @token = data['data']['token']
            Game::Net::Client.username = data['data']['username']
            transmit('auth', 'connected', {status: 200, token: @token}, GameOverseer::Client::HANDSHAKE, true)
            Game::Net::Client.token = @token
          when 400
            puts "#{data['data']['message']}"
            Game::Scene::MultiplayerMenu.instance.messages.color = Gosu::Color::RED
            Game::Scene::MultiplayerMenu.instance.messages.text = "Error <#{data['data']['status']}>: #{data['data']['message']}"
          end

        when 'connected'
          Game::Scene::MultiplayerMenu.instance.messages.color = Gosu::Color::WHITE
          Game::Scene::MultiplayerMenu.instance.messages.text = "Handshake completed. You are now connected to the server."
        end
      end
    end
  end
end
