module Game
  class Server
    class GamePlay < GameOverseer::Service
      def setup
        channel_manager.register_channel("game", self)
        set_safe_methods([:player_moved, :leave])
      end

      def process(data)
        data_to_method(data)
      end

      def player_moved(data)
        players = []

        client_manager.update(client_id, 'angle', data['data']['angle'])
        client_manager.update(client_id, 'x',     data['data']['x'])
        client_manager.update(client_id, 'y',     data['data']['y'])

        client_manager.clients.each do |c|
          players.push({client_id: c[:client_id], username: c[:username], angle: c[:angle], x: c[:x], y: c[:y]})
        end

        data = {channel: 'game', mode: 'player_moved', data: {status: 200, players: players}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def leave(data)
        data = {channel: 'game', mode: 'player_left', data: {status: 200, client_id: client_id}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def client_disconnected(client_id)
        data = {channel: 'game', mode: 'player_left', 'data' => {status: 200, client_id: client_id}}
        message_manager.broadcast(MultiJson.dump(data), true, GameOverseer::ChannelManager::WORLD)
      end

      def version
        '0.0.1'
      end
    end
  end
end
