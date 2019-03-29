module Game
  class Scene
    class Play < GameState
      def setup
        $window.show_cursor = false
        @screen_vector = Vector2D.new(0, 0)
        @screen_scale  = 1.0

        @trackfile = @options[:trackfile] || "data/tracks/test_track.json"
        @track = Track.new(spec: @trackfile)
        if @track.starting_positions.count > 0
          start_position = @track.starting_positions.first
          @car = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])
          start_position = @track.starting_positions[1]
          @car2 = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])
        else
          @car = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
          @car2 = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
        end
        @last_tile = nil

        @color = @track.track.background

        @players   = []
        @viewports = []

        player_1_controls = {
          Gosu.char_to_button_id(Config.get(:player_1_forward)) => :forward,
          Gosu.char_to_button_id(Config.get(:player_1_reverse)) => :reverse,
          Gosu.char_to_button_id(Config.get(:player_1_turn_left)) => :turn_left,
          Gosu.char_to_button_id(Config.get(:player_1_turn_right)) => :turn_right,
          Gosu.char_to_button_id(Config.get(:player_1_headlights)) => :toggle_headlights
        }
        player_2_controls = {
          Gosu.char_to_button_id(Config.get(:player_2_forward)) => :forward,
          Gosu.char_to_button_id(Config.get(:player_2_reverse)) => :reverse,
          Gosu.char_to_button_id(Config.get(:player_2_turn_left)) => :turn_left,
          Gosu.char_to_button_id(Config.get(:player_2_turn_right)) => :turn_right,
          Gosu.char_to_button_id(Config.get(:player_2_headlights)) => :toggle_headlights
        }

        @players << Player.new(actor: @car, controls: player_1_controls, track: @track)
        @players << Player.new(actor: @car2, controls: player_2_controls, track: @track)
        @viewports << Viewport.new(player: @players[0], track: @track, position: :top)
        @viewports << Viewport.new(player: @players[1], track: @track, position: :bottom)
      end

      def players
        @players
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

        @viewports.each { |viewport| viewport.update(@down_keys) }
      end

      def draw_overlay
        return unless @track.track.time_of_day
        case @track.track.time_of_day
        when "morning"
          $window.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.rgba(255,127,0, 50), Float::INFINITY)
        when "noon"
        when "evening"
          $window.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.rgba(0,0,0, 200), Float::INFINITY)
        when "night"
          # TODO: Implement some form of lighting
          $window.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.rgba(0,0,0, 250), Float::INFINITY)
        end
      end

      def button_up(id)
        super
        case id
        when Gosu::KbEscape
          push_game_state(Pause.new(last_state: self))
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
