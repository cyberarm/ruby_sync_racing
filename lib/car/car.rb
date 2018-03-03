class Car < GameObject
  attr_reader :speed, :braking, :changed, :boundry

  def setup
    self.z = 5
    @car_data = CarParser.new(@options[:spec]).data
    @last_x, @last_y, @last_speed = 0, 0, 0

    @image = image(@car_data["spec"]["image"])
    self.scale = @car_data["spec"]["factor"]
    @physics = CarPhysics.new(self)

    @debug = Game::Text.new("", size: 50)
    @username = @options[:username] || "#{@car_data["name"]}"
    @name  = Game::Text.new(@username, size: 20)

    @speed = 0.0

    @drag        = @car_data["spec"]["drag"]
    @top_speed   = @car_data["spec"]["top_speed"]
    @break_speed = @car_data["spec"]["break_speed"]

    # @engine = Gosu::Sample["assets/sound/engine.wav"]
    # @engine_instance = nil

    @brake = sample("assets/sound/brakes.ogg")
    @brake_instance = nil
    @brake_volume   = 0.0

    @braking = false
    @tick = 0
    @yellow_up = false
    @yellow_int = 255
    @tile_size = 64
  end

  def draw
    super
    @debug.draw
    @name.draw

    # Does some kind of transformation to rotate in sync with car
    $window.rotate(self.angle, self.x, self.y) do
      # TODO: fade between 2 colors instead of using Random
      _yellow = Gosu::Color.rgb(@yellow_int, @yellow_int, 0)
      @car_data["spec"]["lights"]["head_lights"].each do |light|
        $window.fill_rect((self.x-(self.width/2))+light["left"],
                           (self.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"], _yellow, 6)
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
        $window.fill_rect((self.x-(self.width/2))+light["left"],
                           (self.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"], _red, 6)
      end
    end
  end

  def update
    super
    @angle = (@angle % 360)
    @tick+=1

    unless inside_boundry?
      puts "#{@x}-#{@last_x}|#{@y}-#{@last_y}|#{@speed}-#{@last_speed}" if DEBUG
      @x = @last_x
      @y = @last_y
      @speed = 0.5#@last_speed
    end

    if @yellow_up
      if @yellow_int >= 255
        @yellow_up = false
      else
        @yellow_int+=1
      end
    else
      if @yellow_int <= 190
        @yellow_up = true
      else
        @yellow_int-=1
      end
    end

    # Engine Sound stuff.
    # Disabled until I can find a decent sound loop
    #
    # if @engine_instance && @engine_instance.playing?
    #   volume = @speed.to_f/@top_speed.to_f
    #   volume.round(2)
    #   volume = 0.1 if volume < 0.1
    #   @engine_instance.volume = volume
    # end

    # unless @braking
      # if @speed <= -0.01 or @speed >= 0.01
      #   if !@engine_instance
      #     @engine_instance = @engine.play(1,1,true)
      #   end
      # end
    # end

    if @braking
      if @speed <= -0.01 or @speed >= 0.01
        # Play braking sound
        if @brake_instance && @brake_instance.playing?
        else
          # Make sure that @speed is a positive number
          _speed = @speed*-1 if @speed < -0.01
          _speed = @speed if @speed > 0.0

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

    @debug.text = "Angle:#{self.angle.round(1)} Speed:#{@speed.round(1)} Pixels Per Frame - FPS:#{Gosu.fps}"
    @name.x,@name.y = self.x-@name.width/2,self.y-self.height*self.scale-24
    @physics.update

    unless @speed >= @top_speed
      @braking = false

      if button_down?(Gosu::KbUp) or button_down?(Gosu::KbW)
        if @speed <= -0.01
          @braking = true
          @speed+=@break_speed
        else
          @braking = false
          @speed+=@top_speed/100.0
        end
      end
    end

    unless @speed <= -@top_speed
      if button_down?(Gosu::KbDown)  or button_down?(Gosu::KbS)
        if @speed >= 0.01
          @speed-=@break_speed
          @braking = true
        else
          @braking = false
          @speed-=@top_speed/100.0
        end
      end
    end

    @speed-=@drag if @speed >= 0.00
    @speed+=@drag if @speed <= -0.00

    if @speed > 0.0
      @angle-=2 if button_down?(Gosu::KbLeft) or button_down?(Gosu::KbA)
      @angle+=2 if button_down?(Gosu::KbRight) or button_down?(Gosu::KbD)
    elsif @speed < 0.0
      @angle+=2 if button_down?(Gosu::KbLeft) or button_down?(Gosu::KbA)
      @angle-=2 if button_down?(Gosu::KbRight) or button_down?(Gosu::KbD)
    end

    @last_x = @x
    @last_y = @y
    @last_speed = @speed
    if @speed.abs <= 0.008 then @speed = 0.0; end
    if @speed == 0.0 then @braking = true; end
  end

  def calc_boundry(track_tiles)
    low_x, low_y  = 0, 0
    high_x, high_y  = 0, 0

    track_tiles.each do |tile|
      if tile.x <= low_x
        low_x = tile.x
      end
      if tile.x >= high_x
        high_x = tile.x
      end

      if tile.y <= low_y
        low_y = tile.y
      end
      if tile.y >= high_y
        high_y = tile.y
      end
    end

    low_x-=@tile_size*4
    low_y-=@tile_size*4
    high_x+=@tile_size*4
    high_y+=@tile_size*4

    @boundry = [low_x, low_y, high_x, high_y]
  end

  def inside_boundry?
    b = false
    if x.between?(@boundry[0], @boundry[2])
      if y.between?(@boundry[1], @boundry[3])
        b = true
      end
    end
    return b
  end
end
