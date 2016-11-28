class Car < Chingu::GameObject
  attr_reader :speed, :braking, :changed, :boundry

  def setup
    self.zorder = 5
    @car_data = Car::Parser.new(@options[:spec]).data

    @image = Gosu::Image[@car_data["spec"]["image"]]
    self.factor = @car_data["spec"]["factor"]
    @physics = Car::Physics.new(self)

    @debug = Game::Text.new("", size: 50)
    @username = @options[:username] || "#{@car_data["name"]}"
    @name  = Game::Text.new(@username, size: 20)

    @speed = 0.0

    @drag        = @car_data["spec"]["drag"]
    @top_speed   = @car_data["spec"]["top_speed"]
    @break_speed = @car_data["spec"]["break_speed"]

    # @engine = Gosu::Sample["assets/sound/engine.wav"]
    # @engine_instance = nil

    @brake = Gosu::Sample["assets/sound/brakes.ogg"]
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
        $window.fill_rect([(self.x-(self.width/2))+light["left"],
                           (self.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"]], _yellow, 6)
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
        $window.fill_rect([(self.x-(self.width/2))+light["left"],
                           (self.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"]], _red, 6)
      end
    end
  end

  def update
    super
    @angle = (@angle % 360)
    @tick+=1

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
    @name.x,@name.y = self.x-@name.width/2,self.y-self.height*self.factor-24
    @physics.update

    unless @speed >= @top_speed
      @braking = false

      if holding?(:up)  or holding?(:w)
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
      if holding?(:down)  or holding?(:s)
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
      @angle-=2 if holding?(:left) or holding?(:a)
      @angle+=2 if holding?(:right) or holding?(:d)
    elsif @speed < 0.0
      @angle+=2 if holding?(:left) or holding?(:a)
      @angle-=2 if holding?(:right) or holding?(:d)
    end
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
end
