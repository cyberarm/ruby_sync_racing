module Game
  class Scene
    class CarSelection < Chingu::GameState
      def setup
        # List cars graphically
        # with top speed, .. ..
        push_game_state(Game)
      end
    end
  end
end
