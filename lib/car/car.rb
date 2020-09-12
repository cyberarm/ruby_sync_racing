class Car < CyberarmEngine::GameObject
  attr_accessor :speed, :braking, :angular_velocity
  attr_reader :braking, :changed, :boundry,
              :drag, :top_speed, :acceleration, :brake_speed, :turn_speed, :angular_drag

  DRAG = 10.0
  TOP_SPEED = 240.0
  BRAKE_SPEED = 120.0
  ACCELERATION = 100.0
  TURN_SPEED = 16.0
  ANGULAR_DRAG = 0.9

  def setup
    self.position.z = 5
    @car_data = CarParser.new(@options[:spec]).data
    @last_x, @last_y, @last_speed = 0, 0, 0

    @image      = get_image(AssetManager.image_from_id(@car_data["spec"]["image"]), retro: false, tileable: true)
    @body_image = get_image(AssetManager.image_from_id(@car_data["spec"]["body_image"]), retro: false, tileable: true)
    @body_color = @options[:body_color] ? @options[:body_color] : Gosu::Color.rgb(rand(0..150), rand(0..150),rand(0..150)) # Gosu::Color::WHITE
    self.scale = @car_data["spec"]["scale"]
    @physics = CarPhysics.new(self)

    @debug = CyberarmEngine::Text.new("", size: 50)
    @username = Config.get(:player_username) || @options[:username] || "#{@car_data["name"]}"
    @name  = CyberarmEngine::Text.new("<b>#{@username}</b>", size: 20, color: lighten(@body_color))

    @speed = 0.0

    @drag        = DRAG         # @car_data["spec"]["drag"]
    @top_speed   = TOP_SPEED    # @car_data["spec"]["top_speed"]
    @acceleration= ACCELERATION # @car_data["spec"]["acceleration"]
    @brake_speed = BRAKE_SPEED  # @car_data["spec"]["brake_speed"]
    @turn_speed  = TURN_SPEED   # @car_data["spec"]["turn_speed"]
    @angular_drag= ANGULAR_DRAG # @car_data["spec"]["angular_drag"]
    @angular_velocity = 0.0


    # @engine = Gosu::Sample["assets/sound/engine.wav"]
    # @engine_instance = nil

    @brake = get_sample(AssetManager.sound_from_id(100))
    @brake_instance = nil
    @brake_volume   = 0.0

    @braking = false
    @headlights_on = false
    @yellow_up = false
    @yellow_int = 255

    @beam_origin_color = Gosu::Color.rgba(190, 190, 0, 100)
    @beam_edge_color   = Gosu::Color.rgba(190, 190, 0, 0)

    @tile_size = 64
    @last_light_toggle = Gosu.milliseconds
    @last_light_toggle_timeout = 100
  end

  def draw
    super
    @body_image.draw_rot(@position.x, @position.y, @position.z, @angle, @center_x, @center_y, @scale_x, @scale_y, @body_color, @mode)
    @debug.draw
    @name.draw

    # Does some kind of transformation to rotate in sync with car
    Gosu.rotate(self.angle, @position.x, @position.y) do
      # TODO: fade between 2 colors instead of using Random
      _yellow = Gosu::Color.rgb(@yellow_int, @yellow_int, 0)
      @car_data["spec"]["lights"]["head_lights"].each do |light|
        draw_rect((@position.x-(self.width/2))+light["left"],
                           (@position.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"], _yellow, 6)
        # Light Beams
        if @headlights_on
          Gosu.draw_quad(@position.x-(self.width/2)+light["left"],
                            @position.y-((self.height/2)), @beam_origin_color,

                            @position.x-(self.width/2)+light["left"],
                            @position.y-((self.height/2)), @beam_origin_color,

                            @position.x-(self.width/2)+light["left"]+50,
                            @position.y-((self.height/2)+150), @beam_edge_color,

                            @position.x-(self.width/2)+light["left"]-50,
                            @position.y-((self.height/2)+150), @beam_edge_color,
                            6
          )
        end
      end

      if @braking
        # Braking
        _red = Gosu::Color.rgb(255, 0, 0)
      elsif @speed <= -0.001
        # Backup lights
        _red = Gosu::Color.rgb(255, 255, 255)
      else
        # Not braking
        _red = Gosu::Color.rgb(140, 0, 0)
      end

      @car_data["spec"]["lights"]["tail_lights"].each do |light|
        draw_rect((@position.x-(self.width/2))+light["left"],
                           (@position.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"], _red, 6)
      end
    end

    show_debug_heading if $debug
  end

  def update
    super
    @angle = (@angle % 359)
    @last_position = @position.clone
    @last_speed = @speed

    unless inside_boundry?
      # puts "#{@x}-#{@last_x}|#{@y}-#{@last_y}|#{@speed}-#{@last_speed}" if $debug
      @position = @last_position
      @speed = 30.0 if @speed > 30.0
      @speed = -30.0 if @speed < -30.0
    end

    flutter_headlights

    # Disabled until I can find a decent sound loop
    # play_engine_sound
    play_braking_sound

    debug_text("Braking: #{@braking}\nX:#{@position.x.round}\nY:#{@position.y.round}\nAngle:#{self.angle.round(1)}\nSpeed:#{@speed.round(1)}\n(Pixels Per Frame)\nFPS:#{Gosu.fps}")
    @physics.update
    @name.x,@name.y = @position.x-@name.width/2, @position.y-self.height
  end

  def forward
    @physics.forward
  end

  def reverse
    @physics.reverse
  end

  def turn_left
    @physics.turn_left
  end

  def turn_right
    @physics.turn_right
  end

  def toggle_headlights
    return unless Gosu.milliseconds >= @last_light_toggle + @last_light_toggle_timeout

    @last_light_toggle = Gosu.milliseconds
    @headlights_on = !@headlights_on
  end

  def flutter_headlights
    if @yellow_up
      if @yellow_int >= 255
        @yellow_up = false
      else
        @yellow_int+=1
      end
    else
      if @yellow_int <= 225
        @yellow_up = true
      else
        @yellow_int-=1
      end
    end
  end

  # Engine Sound stuff.
  def play_engine_sound
    if @engine_instance && @engine_instance.playing?
      volume = @speed.to_f/@top_speed.to_f
      volume.round(2)
      volume = 0.1 if volume < 0.1
      @engine_instance.volume = volume
    end

    unless @braking
      if @speed <= -0.01 or @speed >= 0.01
        if !@engine_instance
          @engine_instance = @engine.play(1,1,true)
        end
      end
    end
  end

  def play_braking_sound
    if @braking
      if @speed <= -0.01 or @speed >= 0.01
        # Play braking sound
        unless @brake_instance && @brake_instance.playing?
          # Make sure that @speed is a positive number
          _speed = @speed.abs

          volume = _speed.to_f/@top_speed.to_f
          volume.round(2)
          volume = 0.1 if volume < 0.1

          speed = volume
          speed = 0.7 unless volume > 0.7

          @brake_instance = @brake.play(volume, speed)
          @brake_volume = volume
        end
      end

    else
      if @brake_instance && @brake_instance.playing?
        @brake_volume-=0.1
        @brake_instance.volume = @brake_volume
        @brake_instance.stop if @brake_volume <= 0.0
      end
    end
  end

  def boundry=boundry
    @boundry = boundry
  end

  def inside_boundry?
    @position.x.between?(@boundry.x, @boundry.max_x) &&
    @position.y.between?(@boundry.y, @boundry.max_y)
  end
end
