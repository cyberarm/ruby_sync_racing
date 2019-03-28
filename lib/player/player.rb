module Game
  class Player
    attr_reader :actor, :name, :local, :controls, :viewport
    def initialize(actor:, name: Config.get(:player_username), local: true, controls: {}, viewport:)
      raise "actor must be a Car" unless actor.is_a?(Car)
      @actor    = actor
      @name     = name.freeze
      @local    = local.freeze
      @controls = controls.freeze
      @viewport = viewport

      @viewport.player = self
    end

    def handle(key)
      return unless @controls.dig(key)

      @actor.send(@controls.dig(key))
    end

    def draw
      @viewport.draw
    end

    def update
      @viewport.update
      @actor.update
    end
  end
end