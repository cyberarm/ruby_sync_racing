class Car < Chingu::GameObject
  attr_reader :speed

  def setup
    @image = Gosu::Image["assets/cars/CAR.png"]
    @physics = Car::Physics.new(self)
    @debug = Chingu::Text.new("", size: 50)

    @speed = 0.0
  end

  def draw
    super
    @debug.draw
  end

  def update
    super
    @debug.text = "X#{self.x.round(2)}:Y#{self.y.round(2)}:Angle#{self.angle.degrees_to_radians.round(2)}:Speed#{@speed.round(2)}"
    @physics.update

    unless @speed >= 5.0
      if holding?(:up)
        if @speed <= -0.1
          @speed+=0.2
        else
          @speed+=0.05
        end
      end
    end

    unless @speed <= -5.0
      if holding?(:down)
        if @speed >= 0.1
          @speed-=0.2
        else
          @speed-=0.05
        end
      end
    end

    @angle-=2 if holding?(:left)
    @angle+=2 if holding?(:right)
  end
end
