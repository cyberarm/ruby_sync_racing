module Game
  class Countdown
    attr_reader :duration, :time
    def initialize(duration: 3_000)
      @duration = duration

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
      @time >= @duration
    end

    def draw(viewport)
      draw_countdown(viewport)
    end

    def update
      if @running
        @time += Window.dt * 1000.0

        @text_scale -= Window.dt * @text_initial_scale

        if @last_text != @text.text && !@text.text.empty?
          @last_text = @text.text
          @text_scale = @text_initial_scale

          if time_left <= 0
            $window.current_state.get_sample("assets/track_editor/error.ogg").play(2)
          else
            $window.current_state.get_sample("assets/track_editor/error.ogg").play(2)
            $window.current_state.get_sample("assets/track_editor/click.ogg").play(2)
          end
        end

        if time_left > 0
          @text.text = "#{time_left.ceil}"
        elsif time_left <= 0 && time_left > -1
          @text.text = "GO!"
        else
          @text.text = ""
        end
      end
    end

    def draw_countdown(viewport)
      @text.x = (viewport.x + viewport.width / 2)  - @text.width / 2
      @text.y = (viewport.y + viewport.height / 2) - @text.height/ 2

      Gosu.draw_rect(
        viewport.x, viewport.y,
        viewport.width, viewport.height,
        Gosu::Color.rgba(0,0,0, 255.0 * factor), 8181
      )

      Gosu.scale(@text_scale, @text_scale, viewport.x + viewport.width / 2, viewport.y + viewport.height / 2) do
        @text.draw
      end
    end

    def time_left
      (@duration - @time) / 1000.0
    end

    def race_time
      ((@time - @duration) / 1000.0)
    end

    def factor
      (time_left.to_f / (@duration / 1000.0))
    end
  end
end