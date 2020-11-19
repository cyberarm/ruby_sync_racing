module Game
  class AIPlayer < Player
    class Sensor
      def initialize(player:, normal:, ray_length:)
        @player = player
        @normal = normal
        @ray_length = ray_length

        @angle = Math.atan2(@normal.y, @normal.x).radians_to_degrees

        @color_okay = Gosu::Color.new(0xff_00aa00)
        @color_not_okay = Gosu::Color.new(0xff_800000)

        @color = @color_okay

        @sensing = true
      end

      def draw
        angle = @player.actor.angle + @angle

        Gosu.rotate(angle, @player.actor.position.x, @player.actor.position.y) do
          Gosu.draw_rect(@player.actor.position.x, @player.actor.position.y, 2, -@ray_length, @color, Float::INFINITY)
        end

        heading = @normal * @ray_length
        x = @player.actor.position.x + heading.x
        y = @player.actor.position.y + heading.y

        Gosu.draw_circle(x, y, 8, 6, @color)
      end

      def update
        heading = @normal * @ray_length
        x = @player.actor.position.x + heading.x
        y = @player.actor.position.y + heading.y
        tile = @player.track.collision.find(x, y)

        if tile && tile.type == "asphalt"
          @color = @color_okay
          @sensing = true
        else
          @color = @color_not_okay
          @sensing = false
        end
      end

      def sensing?
        @sensing
      end
    end

    def initialize(actor:, name: Config.get(:player_username), local: true, controls: {}, track:)
      super

      @name = "<i>[BOT] #{@name}</i>".freeze
      @nametag.text = @name

      @sensors = [
        Sensor.new(player: self, normal: CyberarmEngine::Vector.new(0, -1), ray_length: 64), # Left of Car
        Sensor.new(player: self, normal: CyberarmEngine::Vector.new(1, -1), ray_length: 64), # Front Left of Car
        Sensor.new(player: self, normal: CyberarmEngine::Vector.new(1,  0), ray_length: 64 * 3), # Front of Car
        Sensor.new(player: self, normal: CyberarmEngine::Vector.new(1, 1), ray_length: 64), # Front Right of Car
        Sensor.new(player: self, normal: CyberarmEngine::Vector.new(0, 1), ray_length: 64), # Right of Car
      ]
    end

    def handle(button)
    end

    def draw
      @sensors.each(&:draw)

      @track.tiles.select { |t| t.type == "asphalt" }.each do |tile|
        Gosu.draw_rect(tile.x, tile.y, 64, 64, Gosu::Color.new(0x88_222222))
      end
    end

    def update
      super
      @sensors.each(&:update)

      @actor.forward if Gosu.button_down?(Gosu::KB_W)
      @actor.turn_left if Gosu.button_down?(Gosu::KB_A)
      @actor.turn_right if Gosu.button_down?(Gosu::KB_D)
      @actor.reverse if Gosu.button_down?(Gosu::KB_S)

      # @actor.speed = 10.0
    end
  end
end