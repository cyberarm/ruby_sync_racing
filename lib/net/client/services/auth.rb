module Game
  module Net
    class Auth < GameOverseer::Client::Service
      def setup
        register_channel("auth")
      end

      def process_data(data, channel)
        p data
        case data['mode']
        when 'connect'
          case data['data']['status']
          when 200
            token = data['data']['token']
            transmit('auth', 'connected', {status: 200, token: token}, GameOverseer::Client::HANDSHAKE, true)
          when 400
            puts "#{data['data']['message']}"
          end
        when 'connected'
          Game::Scene::MultiplayerMenu.instance.messages.text = "Handshake completed. You are now connected to the server."
        end
      end
    end
  end
end
