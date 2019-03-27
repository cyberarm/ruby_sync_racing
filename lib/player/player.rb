module Game
  class Player
    attr_reader :actor, :name, :local, :controls
    def initialize(actor:, name: Config.get(:player_username), local: true, controls: {})
      raise "actor must be a Car" unless actor.is_a?(Car)
      @actor    = actor
      @name     = name.freeze
      @local    = local.freeze
      @controls = controls.freeze
    end

    def handle(key)
      return unless @controls.dig(key)

      @actor.send(@controls.dig(key))
    end
  end
end