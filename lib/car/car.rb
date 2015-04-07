class Car < Chingu::GameObject
  attr_reader :speed, :braking

  def setup
    self.zorder = 5
    @car_data = Car::Parser.new(@options[:spec]).data

    @image = Gosu::Image[@car_data["spec"]["image"]]
    self.factor = @car_data["spec"]["factor"]
    @physics = Car::Physics.new(self)

    @debug = Game::Text.new("", size: 50)
    @name  = Game::Text.new("#{@car_data["name"]}", size: 20)

    @speed = 0.0

    @drag        = @car_data["spec"]["drag"]
    @top_speed   = @car_data["spec"]["top_speed"]
    @break_speed = @car_data["spec"]["break_speed"]

    @braking = false
    @tick = 0
    @yellow_up = false
    @yellow_int = 255
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

    @debug.text = "Angle:#{self.angle.round(1)} Speed:#{@speed.round(1)} Pixels Per Frame - FPS:#{Gosu.fps}"
    @name.x,@name.y = self.x-@name.width/2,self.y-self.height*self.factor-24
    @physics.update

    unless @speed >= @top_speed
      @braking = false

      if holding?(:up)
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
      if holding?(:down)
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

    if @speed >= 0.0
      @angle-=2 if holding?(:left)
      @angle+=2 if holding?(:right)
    else
      @angle+=2 if holding?(:left)
      @angle-=2 if holding?(:right)
    end
  end
end
