module Game
  class Scene
    class Play < CyberarmEngine::GameState
      attr_reader :game_data

      def setup
        window.show_cursor = false
        @screen_vector = CyberarmEngine::Vector.new(0, 0)
        @screen_scale  = 1.0

        @trackfile = @options[:trackfile] || "data/tracks/test_track.json"

        @game_data = GameData.new(
          track: Track.new(spec: @trackfile),
          players: [],
          countdown: Countdown.new(duration: 3_000),
          laps: 3
        )

        if @game_data.track.starting_positions.count > 0
          start_position = @game_data.track.starting_positions.first
          @car = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])

          start_position = @game_data.track.starting_positions[1]
          @car2 = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])
        else
          @car = Car.new(x: window.width/2, y: window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
          @car2 = Car.new(x: window.width/2, y: window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
        end

        @color = @game_data.track.track.background

        @viewports = []

        player_1_controls = {
          Gosu.char_to_button_id(Config.get(:player_1_forward)) => :forward,
          Gosu.char_to_button_id(Config.get(:player_1_reverse)) => :reverse,
          Gosu.char_to_button_id(Config.get(:player_1_turn_left)) => :turn_left,
          Gosu.char_to_button_id(Config.get(:player_1_turn_right)) => :turn_right,
          Gosu.char_to_button_id(Config.get(:player_1_headlights)) => :toggle_headlights
        }

        @game_data.add_player( Player.new(actor: @car, controls: player_1_controls, track: @game_data.track) )
        @game_data.add_player( AIPlayer.new(actor: @car2, controls: {}, track: @game_data.track) )
        @viewports << PlayerViewport.new(game_data: @game_data, player: @game_data.players[0], position: nil)

        @viewports.each { |viewport| viewport.lag=(0.9) }

        @game_data.countdown.start
      end

      def draw
        draw_overlay

        @viewports.each do |viewport|
          viewport.draw
        end

        fill(@color, -1)
      end

      def update
        super
        @game_data.countdown.update

        @viewports.each { |viewport| viewport.update(@down_keys) }

        # Human players are updated from their viewport, while AI players are not
        @game_data.ai_players.each(&:update) if @game_data.countdown.complete?
      end

      def draw_overlay
        return unless @game_data.track.track.time_of_day
        case @game_data.track.track.time_of_day
        when "morning"
          window.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgba(255,127,0, 50), Float::INFINITY)
        when "noon"
        when "evening"
          window.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgba(0,0,0, 200), Float::INFINITY)
        when "night"
          # TODO: Implement some form of lighting
          window.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgba(0,0,0, 250), Float::INFINITY)
        end
      end

      def button_up(id)
        super
        case id
        when Gosu::KbEscape
          push_state(Pause.new(last_state: self))
        when Gosu::Kb0
          @screen_scale = 1.0 if $debug
        when Gosu::MsWheelUp
          @screen_scale+=0.01 if $debug
        when Gosu::MsWheelDown
          @screen_scale-=0.01 if $debug
          @screen_scale = 0.001 if @screen_scale < 0 && $debug
        end
      end
    end
  end
end
