class Car < Chingu::GameObject
  attr_reader :speed

  def setup
    self.zorder = 5
    @car_data = Car::Parser.new(@options[:spec]).data

    @image = Gosu::Image[@car_data["spec"]["image"]]
    self.factor = @car_data["spec"]["factor"]
    @physics = Car::Physics.new(self)

    @debug = Game::Text.new("", size: 50)
    @name  = Game::Text.new("#{@car_data["name"]}", size: 30)

    @speed = 0.0

    @drag        = @car_data["spec"]["drag"]
    @top_speed   = @car_data["spec"]["top_speed"]
    @break_speed = @car_data["spec"]["break_speed"]

    @braking = false
    @tick = 0
  end

  def draw
    super
    @debug.draw
    @name.draw

    # Do some kind of transformation to rotate in sync with car
    $window.rotate(self.angle, self.x, self.y) do
      _yellow = Gosu::Color.rgb(rand(255), rand(255), 0) # Flicker
      @car_data["spec"]["lights"]["head_lights"].each do |light|
        $window.fill_rect([(self.x-(self.width/2))+light["left"],
                           (self.y-(self.height/2))+light["top"],
                           light["width"],
                           light["height"]], _yellow, 6)
      end

      _red = Gosu::Color.rgb(rand(255), 0, 0) # Flicker
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

    @debug.text = "Angle:#{self.angle.round(1)} Speed:#{@speed.round(1)} Pixels Per Frame - #{Gosu.fps}"
    @name.x,@name.y = self.x-@name.width/2,self.y-@name.height
    @physics.update

    unless @speed >= @top_speed
      if holding?(:up)
        if @speed <= -0.1
          @braking = true
          @speed+=@break_speed
        else
          @speed+=@top_speed/100.0
        end
      end
    end

    unless @speed <= -@top_speed
      if holding?(:down)
        if @speed >= 0.1
          @speed-=@break_speed
          @braking = true
        else
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
