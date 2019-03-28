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
          @car2 = Car.new(x: start_position[:x], y: start_position[:y], angle: start_position[:angle], spec: @options[:carfile], body_color: @options[:body_color])
        else
          @car = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
          @car2 = Car.new(x: $window.width/2, y: $window.height/2, spec: @options[:carfile], body_color: @options[:body_color])
        end
        @last_tile = nil

        @color = @track.track.background
        @car.boundry = @track.bounding_box
        @car2.boundry = @track.bounding_box
        puts "Car boundry: #{@car.boundry}"

        @countdown_text = Text.new("Text", z: 8182, size: 48)
        @countdown_time_started = Gosu.milliseconds
        @countdown_time = 3_000

        @players = []

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

        player_1_viewport = Viewport.new(track: @track, x: 0, y: 0, width: $window.width, height: $window.height/2)
        player_2_viewport = Viewport.new(track: @track, x: 0, y: $window.height/2, width: $window.width, height: $window.height/2)
        @players << Player.new(actor: @car, controls: player_1_controls, viewport: player_1_viewport)
        @players << Player.new(actor: @car2, controls: player_2_controls, viewport: player_2_viewport)
      end

      def draw
        draw_overlay
        draw_countdown

        @players.each do |player|
          player.draw
        end

        fill(@color, -1)
      end

      def update
        super
        if ((@countdown_time_started + @countdown_time) - Gosu.milliseconds) / 1000.0 <= 0
          @down_keys.each do |key, value|
            @players.each { |player|player.handle(key) }
          end
        end
        @players.each { |player| player.update }
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

      def draw_countdown
        time_left = ((@countdown_time_started + @countdown_time) - Gosu.milliseconds)/1000.0

        if time_left > 0
          @countdown_text.text = "#{time_left.round(1)} seconds"
          @countdown_text.x = @car.x - @countdown_text.width/2
          @countdown_text.y = @car.y - @countdown_text.height/2
          $window.draw_rect(
            @countdown_text.x - 10, @countdown_text.y - 10,
            @countdown_text.width + 20, @countdown_text.height + 20,
            Gosu::Color.rgba(0,0,0, 255.0 * (time_left.to_f / (@countdown_time/1000.0))), 8181
          )
          @countdown_text.draw
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
