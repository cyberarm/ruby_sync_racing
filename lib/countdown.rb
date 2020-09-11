module Game
  class Countdown
    def initialize(viewport:, period: 3_000)
      @viewport = viewport
      @period = period

      @time = 0
      @running = false

      @text = CyberarmEngine::Text.new("Waiting...", z: 8182, size: 48)
      @last_text = @text.text

      @text_initial_scale = 3.0
      @text_min_scale = 1.0
      @text_scale = @text_initial_scale
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
        @time += Window.dt * 1000.0

        @text_scale -= Window.dt * @text_initial_scale

        if @last_text != @text.text
          @last_text = @text.text
          @text_scale = @text_initial_scale
        end

        if time_left > 0
          @text.text = "#{time_left.ceil}"
        elsif time_left <= 0 && time_left > -1
          @text.text = "GO!"
        else
          @text.text = ""
        end

        @text.x = (@viewport.x + @viewport.width/2)  - @text.width / 2
        @text.y = (@viewport.y + @viewport.height/2) - @text.height/ 2
      end
    end

    def draw_countdown
      Gosu.draw_rect(
        @viewport.x, @viewport.y,
        @viewport.width, @viewport.height,
        Gosu::Color.rgba(0,0,0, 255.0 * factor), 8181
      )

      Gosu.scale(@text_scale, @text_scale, @viewport.x + @viewport.width / 2, @viewport.y + @viewport.height / 2) do
        @text.draw
      end
    end

    def time_left
      (@period - @time) / 1000.0
    end

    def factor
      (time_left.to_f / (@period / 1000.0))
    end
  end
end