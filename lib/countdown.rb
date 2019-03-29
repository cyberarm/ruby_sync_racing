module Game
  class Countdown
    def initialize(viewport:, period: 3_000)
      @viewport = viewport
      @period = period

      @time = 0
      @running = false

      @text = Text.new("", z: 8182, size: 48)
    end

    def start
      @running = true
    end

    def pause
      @running = false
    end

    def complete?
      @time >= @period
    end

    def draw
      draw_countdown
    end

    def update
      if @running
        @time += Display.dt * 1000.0
      end
    end

    def draw_countdown
      if time_left > 0
        @text.text = "#{time_left.round(1)} seconds"
        @text.x = (@viewport.x + @viewport.width/2)  - @text.width / 2
        @text.y = (@viewport.y + @viewport.height/2) - @text.height/ 2

        $window.draw_rect(
          @text.x - 10, @text.y - 10,
          @text.width + 20, @text.height + 20,
          Gosu::Color.rgba(0,0,0, 255.0 * factor), 8181
        )

        @text.draw
      end
    end

    def time_left
      (@period - @time) / 1000.0
    end

    def factor
      time_left.to_f / (@period / 1000.0)
    end
  end
end