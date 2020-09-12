module Game
  class Player
    class View < Viewport
      def initialize(game:, player:, position:)
        super(position: position)

        @player = player
        @game = game

        @laps = 3
        @completed_laps = 0

        @checkpoints = @game.track.checkpoints.size
        @checkpoints_list = []

        @remaining_laps = CyberarmEngine::Text.new("", x: @x + 10, y: @y + 10, z: 8181, size: 28, color: Gosu::Color::BLACK)
        @race_time = CyberarmEngine::Text.new("", x: @x + 10, y: @y + 10, z: 8181, size: 28, color: Gosu::Color::BLACK)

        @border_color = Gosu::Color::BLACK

        @countdown = Countdown.new(viewport: self)
        @countdown.start

        @speed_ratio = 0.0

        center_around(@player.actor)
      end

      def render
        @remaining_laps.draw
        @race_time.draw
        @countdown.draw
      end

      def render_transformed
        @game.track.draw
        @game.players.each do |player|
          player.actor.draw
        end

        if $debug
          draw_bounding_box(@game.track.bounding_box)

          (@game.track.checkpoints - @checkpoints_list).each do |checkpoint|
            Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(200,200,200, 200), 5)
          end

          @checkpoints_list.each do |checkpoint|
            Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(100,200,100, 200), 5)
          end
        end
      end

      def update(keys)
        super()

        @countdown.update

        @race_time.x, @race_time.y = @x + 10, @y + 10
        @remaining_laps.x, @remaining_laps.y = @x + 10 + (@width / 2 - @remaining_laps.width / 2), @y + 10
        @speed_ratio = (@player.actor.speed.abs / @player.actor.top_speed)
        @scale = 1.75 - @speed_ratio

        if @countdown.complete?
          keys.each do |key, value|
            @player.handle(key)
          end

          @race_time.text = "Time: #{"%0.02f" % race_time}"
        else
          @race_time.text = "Time: 0.00"
        end

        # move_towards(@player.actor)
        move_ahead_of(@player.actor, 100.0 * @speed_ratio)
        @remaining_laps.text = "Laps: #{@completed_laps}/#{@laps}"

        lap_check if @game.track.checkpoints.size > 0
        @player.update
      end

      def race_time
        ((@countdown.time - @countdown.period) / 1000.0)
      end

      def lap_check
        rejectable = nil
        ((@game.track.checkpoints)-@checkpoints_list).each do |checkpoint|
          if @player.actor.position.x.between?(checkpoint.x, checkpoint.x + checkpoint.width)
            if @player.actor.position.y.between?(checkpoint.y, checkpoint.y + checkpoint.height)
              # puts "CHECKPOINT: #{checkpoint}"
              rejectable = checkpoint
              @checkpoints_list << checkpoint unless checkpoint == @lap_rejectable
            end
          end
        end

        @lap_rejectable = nil if rejectable != @lap_rejectable

        if @game.track.checkpoints.size == @checkpoints_list.size
          @completed_laps += 1
          @checkpoints_list.clear
          @lap_rejectable = rejectable
        end

        if @completed_laps == @laps
          # TODO: Show a Race Finished Screen
          $window.current_state.push_state(Game::Scene::MainMenu)
        end
      end
    end
  end
end