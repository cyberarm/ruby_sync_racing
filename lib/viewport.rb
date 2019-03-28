module Game
  class Viewport
    attr_accessor :player
    def initialize(track:, x:, y:, width:, height:)
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
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        @car_text.draw
        @player.actor.draw

        Gosu.scale(@scale, @scale, @x + @width / 2, @y + @height / 2) do
          Gosu.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
            @track.draw

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

    def update
      center_around(@player.actor)
      @car_text.text = "Car speed: #{@player.actor.speed.round} x: #{@player.actor.x.round}, y: #{@player.actor.y.round}, angle: #{@player.actor.angle.round}.\nLaps: #{@completed_laps}/#{@laps}, Checkpoints: #{@checkpoints_list.size}/#{@track.checkpoints.size}"

      lap_check if @track.checkpoints.size > 0
    end

    def center_around(entity)
      @screen_vector.x = ((entity.x - @x) - @width / 2)
      @screen_vector.y = ((entity.y - @y) - @height / 2)
    end

    def draw_bounding_box(box)
      $window.current_game_state.draw_bounding_box(box)
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
        push_game_state(MainMenu)
      end
    end
  end
end