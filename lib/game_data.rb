module Game
  class GameData
    attr_reader :track, :players, :countdown, :laps, :ai_players
    def initialize(track:, players:, countdown:, laps:)
      @track = track
      @players = players
      @countdown = countdown
      @laps = laps

      @ai_players = []
    end

    def add_player(player)
      @players << player
      @ai_players << player if player.is_a?(AIPlayer)
    end

    def update
      if @countdown.complete?
        @ai_players.each(&:update)
      end
    end
  end
end