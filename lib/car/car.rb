class Car < Chingu::GameObject
  attr_reader :speed

  def setup
    @car_data = Car::Parser.new(@options[:spec]).data

    @image = Gosu::Image[@car_data["spec"]["image"]]
    @physics = Car::Physics.new(self)

    @debug = Chingu::Text.new("", size: 50)

    @speed = 0.0

    @drag = Integer(@car_data["spec"]["drag"])/100.0
    @top_speed   = Integer(@car_data["spec"]["top_speed"])/100.0
    @break_speed = Integer(@car_data["spec"]["break_speed"])/100.0

    @braking = false
    @tick = 0
  end

  def draw
    super
    @debug.draw
  end

  def update
    super
    @tick+=1

    @debug.text = "Angle:#{self.angle.round(2)} Speed:#{@speed.round(2)}"
    @physics.update

    unless @speed >= @top_speed
      if holding?(:up)
        if @speed <= -0.1
          @braking = true
          @speed+=@break_speed
        else
          @speed+=0.05
        end
      end
    end

    unless @speed <= -@top_speed
      if holding?(:down)
        if @speed >= 0.1
          @speed-=@break_speed
          @braking = true
        else
          @speed-=0.05
        end
      end
    end

    @speed-=@drag if @speed >= 0.00
    @speed+=@drag if @speed <= -0.00

    @angle-=2 if holding?(:left)
    @angle+=2 if holding?(:right)
  end
end
