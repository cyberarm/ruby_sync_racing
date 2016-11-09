module Game
  class Server
    class Auth < GameOverseer::Service
      def setup
        channel_manager.register_channel("auth", self)
        set_safe_methods([:connect, :connected])
      end

      def process(data)
        p data
        data_to_method(data)
      end

      def connect(data)
        username_in_use = client_manager.clients.detect do |client|
          if client['username'] == data['data']['username']
            true
          end
        end

        blank = true if data['data']['username'].length < 2
        blank = false if data['data']['username'].length >= 2

        if !username_in_use && !blank
          puts "#{data["data"]["username"]} connected."

          client_manager.update(client_id, 'username', data["data"]["username"])
          token = SecureRandom.hex(24)
          client_manager.update(client_id, 'token', token)
          data = {'channel' => 'auth', 'mode' => 'connect', 'data' => {status: 200, client_id: client_id, token: "#{token}", username: "#{data["data"]["username"]}"}}
          message_manager.message(client_id, MultiJson.dump(data), true, GameOverseer::ChannelManager::HANDSHAKE)
        else
          if username_in_use
            puts "#{data["data"]["username"]} is already connected."
            data = {'channel' => 'auth', 'mode' => 'connect', 'data' => {status: 400, message: "Username '#{data["data"]["username"]}' is already in use."}}

          elsif blank
            puts "Username is less than 2 characters long."
            data = {'channel' => 'auth', 'mode' => 'connect', 'data' => {status: 400, message: "Username is less than 2 characters long."}}
          end
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
        end
      end

      def version
        '0.0.1'
      end
    end
  end
end
