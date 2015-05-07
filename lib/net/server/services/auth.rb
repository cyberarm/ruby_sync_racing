module Server
  class Server
    class Auth < GameOverseer::Service
      def setup
        channel_manager.register_channel("auth", self)
      end

      def process(data)
        data_to_method(data)
      end

      def connect(data)
        if client_manager.get(client_id)['username'] == nil
          puts "#{data["data"]["username"]} connected."
          token = SecureRandom.hex(24)
          client_manager.update(client_id, 'username', data["data"]["username"])
          client_manager.update(client_id, 'username', token)
          data = {'channel' => 'auth', 'mode' => 'connect', 'data' => {status: 200, token: "#{token}"}}
          message_manager.message(client_id, MultiJson.dump(data), true, GameOverseer::ChannelManager::HANDSHAKE)
        else
          puts "#{data["data"]["username"]} is already connected."
          data = {'channel' => 'auth', 'mode' => 'connect', 'data' => {status: 400, message: "#{data["data"]["username"]} is already connected."}}
          message_manager.message(client_id, MultiJson.dump(data), true, GameOverseer::ChannelManager::HANDSHAKE)
        end
      end

      def connected(data)
        if data['data']['status'] == 200
          data = {'channel' => 'auth', 'mode' => 'connected', 'data' => {status: 200}}
          message_manager.message(client_id, MultiJson.dump(data), true, GameOverseer::ChannelManager::HANDSHAKE)
          client_manager.update(client_id, 'online', true)
          # Finished handshake
          # TODO: player things
          p data
        end
      end

      def version
        '0.0.1'
      end
    end
  end
end
