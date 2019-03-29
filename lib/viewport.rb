module Game
  class Viewport
    def initialize(player:, track:, x:, y:, width:, height:)
      @player = player
      @track  = track
      @x, @y  = x, y
      @width, @height = width, height


      @screen_vector = Vector2D.new(0.0, 0.0)
      @scale = 1.0

      @laps = 3
      @completed_laps = 0

      @checkpoints = @track.checkpoints.size
      @checkpoints_list = []

      @car_text = Text.new("", x: @x + 10, y: @y + 10, z: 8181, size: 28, color: Gosu::Color::BLACK)

      @countdown_text = Text.new("", z: 8182, size: 48)
      @countdown_time_started = Gosu.milliseconds
      @countdown_time = 3_000

      @border_color = Gosu::Color::BLACK
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        draw_border
        @car_text.draw
        draw_countdown

        Gosu.scale(@scale, @scale, @x + @width / 2, @y + @height / 2) do
          Gosu.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
            @track.draw
            # @player.actor.draw
            if $window.current_game_state.is_a?(Game::Scene::Play)
              $window.current_game_state.players.each do |player|
                player.actor.draw
              end
            end

            if $debug
              draw_bounding_box(@track.bounding_box)

              (@track.checkpoints-@checkpoints_list).each do |checkpoint|
                Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(200,200,200, 200), 5)
              end

              @checkpoints_list.each do |checkpoint|
                Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(100,200,100, 200), 5)
              end
            end
          end
        end
      end
    end

    def update(keys)
      if ((@countdown_time_started + @countdown_time) - Gosu.milliseconds) / 1000.0 <= 0
        keys.each do |key, value|
          @player.handle(key)
        end
      end

      center_around(@player.actor)
      @car_text.text = "Car speed: #{@player.actor.speed.round} x: #{@player.actor.x.round}, y: #{@player.actor.y.round}, angle: #{@player.actor.angle.round}.\nLaps: #{@completed_laps}/#{@laps}, Checkpoints: #{@checkpoints_list.size}/#{@track.checkpoints.size}"

      lap_check if @track.checkpoints.size > 0
      @player.update
    end

    def center_around(entity)
      @screen_vector.x = ((entity.x - @x) - @width / 2)
      @screen_vector.y = ((entity.y - @y) - @height / 2)
    end

    def draw_bounding_box(box)
      $window.current_game_state.draw_bounding_box(box)
    end

    def draw_border
      $window.draw_line(@x+@width, @y, @border_color, @x+@width, @y+@height, @border_color, Float::INFINITY)  # Right
      $window.draw_line(@x+@width, @y+@height, @border_color, @x, @y+@height, @border_color, Float::INFINITY) # Bottom
      $window.draw_line(@x+1, @y+@height, @border_color, @x+1, @y, @border_color, Float::INFINITY) # Left
      $window.draw_line(@x, @y+1, @border_color, @x+@width, @y+1, @border_color, Float::INFINITY) # Top
    end

    def draw_countdown
      time_left = ((@countdown_time_started + @countdown_time) - Gosu.milliseconds)/1000.0

      if time_left > 0
        @countdown_text.text = "#{time_left.round(1)} seconds"
        @countdown_text.x = (@x + @width/2) - @countdown_text.width / 2
        @countdown_text.y = (@y + @height/2) - @countdown_text.height/ 2
        $window.draw_rect(
          @countdown_text.x - 10, @countdown_text.y - 10,
          @countdown_text.width + 20, @countdown_text.height + 20,
          Gosu::Color.rgba(0,0,0, 255.0 * (time_left.to_f / (@countdown_time/1000.0))), 8181
        )
        @countdown_text.draw
      end
    end

    def lap_check
      rejectable = nil
      ((@track.checkpoints)-@checkpoints_list).each do |checkpoint|
        if @player.actor.x.between?(checkpoint.x, checkpoint.x+checkpoint.width)
          if @player.actor.y.between?(checkpoint.y, checkpoint.y+checkpoint.height)
            # puts "CHECKPOINT: #{checkpoint}"
            rejectable = checkpoint
            @checkpoints_list << checkpoint unless checkpoint == @lap_rejectable
          end
        end
      end

      @lap_rejectable = nil if rejectable != @lap_rejectable

      if @track.checkpoints.size == @checkpoints_list.size
        @completed_laps+=1
        @checkpoints_list.clear
        @lap_rejectable = rejectable
      end

      if @completed_laps == @laps
        $window.current_game_state.push_game_state(Game::Scene::MainMenu)
      end
    end
  end
end