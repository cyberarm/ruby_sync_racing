module Game
  class AIPlayer < Player
    def initialize(actor:, name: Config.get(:player_username), local: true, controls: {}, track:)
      super

      @name = "[BOT]#{@name}"
      @nametag.text = @name
    end

    def handle(button)
    end

    def update
      puts "UPDATING BOT"
      super

      @actor.forward
    end
  end
end