module Game
  class PlayerViewport < Viewport
    def initialize(game_data:, player:, position:)
      super(position: position)

      @player = player
      @game_data = game_data

      @laps = 3
      @completed_laps = 0

      @checkpoints = @game_data.track.checkpoints.size
      @checkpoints_list = []

      @remaining_laps = CyberarmEngine::Text.new("", x: @x + 10, y: @y + 10, z: 8181, size: 28, color: Gosu::Color::BLACK)
      @race_time = CyberarmEngine::Text.new("", x: @x + 10, y: @y + 10, z: 8181, size: 28, color: Gosu::Color::BLACK)

      @border_color = Gosu::Color::BLACK

      @speed_ratio = 0.0

      center_around(@player.actor)
    end

    def render
      @remaining_laps.draw
      @race_time.draw
      @game_data.countdown.draw(self)
    end

    def render_transformed
      @game_data.track.draw
      @game_data.players.each do |player|
        player.actor.draw
        player.nametag.draw
      end

      @game_data.ai_players.each(&:draw)

      if $debug
        draw_bounding_box(@game_data.track.bounding_box)

        (@game_data.track.checkpoints - @checkpoints_list).each do |checkpoint|
          Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(200,200,200, 200), 5)
        end

        @checkpoints_list.each do |checkpoint|
          Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(100,200,100, 200), 5)
        end
      end
    end

    def update(keys)
      super()

      @race_time.x, @race_time.y = @x + 10, @y + 10
      @remaining_laps.x, @remaining_laps.y = @x + 10 + (@width / 2 - @remaining_laps.width / 2), @y + 10
      @speed_ratio = (@player.actor.speed.abs / @player.actor.top_speed)
      @scale = 1.75 - @speed_ratio

      if @game_data.countdown.complete?
        keys.each do |key, value|
          @player.handle(key)
        end

        @race_time.text = "Time: #{"%0.02f" % @game_data.countdown.race_time}"
      else
        @race_time.text = "Time: 0.00"
      end

      # move_towards(@player.actor)
      move_ahead_of(@player.actor, 100.0 * @speed_ratio)
      @remaining_laps.text = "Laps: #{@completed_laps}/#{@laps}"

      lap_check if @game_data.track.checkpoints.size > 0
      @player.update
    end

    def lap_check
      rejectable = nil
      ((@game_data.track.checkpoints)-@checkpoints_list).each do |checkpoint|
        if @player.actor.position.x.between?(checkpoint.x, checkpoint.x + checkpoint.width)
          if @player.actor.position.y.between?(checkpoint.y, checkpoint.y + checkpoint.height)
            # puts "CHECKPOINT: #{checkpoint}"
            rejectable = checkpoint
            @checkpoints_list << checkpoint unless checkpoint == @lap_rejectable
          end
        end
      end

      @lap_rejectable = nil if rejectable != @lap_rejectable

      if @game_data.track.checkpoints.size == @checkpoints_list.size
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