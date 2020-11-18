module Game
  class Player
    attr_reader :actor, :name, :local, :controls, :nametag
    def initialize(actor:, name: Config.get(:player_username), local: true, controls: {}, track:)
      raise "actor must be a Car" unless actor.is_a?(Car)
      @actor    = actor
      @name     = name.freeze
      @local    = local.freeze
      @controls = controls.freeze
      @track    = track

      @nametag = CyberarmEngine::Text.new("<b>#{@name}</b>", size: 20, color: Gosu::Color::WHITE)

      @actor.boundry = @track.bounding_box
    end

    def handle(key)
      return unless @controls.dig(key)

      @actor.send(@controls.dig(key))
    end

    def draw
      @viewport.draw
    end

    def update
      @actor.update

      @nametag.x = @actor.position.x - @nametag.width / 2
      @nametag.y = @actor.position.y - @actor.height
    end
  end
end