module Game
  class Server
    class Lobby < GameOverseer::Service
      def setup
        channel_manager.register_channel("lobby", self)
        set_safe_methods([:join, :ready, :leave])
        @started = false
      end

      def process(data)
        data_to_method(data)
      end

      def enable
        every 100 do
          unless @started
            start = 0
            if client_manager.clients.count > 1
              client_manager.clients.each do |client|
                start+=1 if client[:lobby_ready]
              end
            end

            if start == client_manager.clients.count && client_manager.clients.count > 1
              client_manager.clients.each {|c| c[:lobby_ready] = false}
              data = {channel: 'lobby', mode: 'start', data: {status: 200}}
              message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
            end
          end
        end
      end

      def join(data)
        players = []
        client_manager.update(client_id, 'lobby_ready', false)

        client_manager.clients.each do |c|
          players.push({client_id: c[:client_id], username: c[:username], ready: c[:lobby_ready]})
        end

        data = {channel: 'lobby', mode: 'player_joined', data: {status: 200, players: players}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def ready(data)
        client_manager.update(client_id, 'lobby_ready', data['data']['ready'])
        data = {channel: 'lobby', mode: 'ready', data: {status: 200, client_id: client_id, ready: data['data']['ready']}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def leave(data)
        data = {channel: 'lobby', mode: 'player_left', data: {status: 200, client_id: client_id}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def client_disconnected(client_id)
        data = {channel: 'lobby', mode: 'player_left', 'data' => {status: 200, client_id: client_id}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def version
        '0.0.1'
      end
    end
  end
end
