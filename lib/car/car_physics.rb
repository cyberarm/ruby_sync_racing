class Car
  class Physics
    attr_reader :angle
    def initialize(car_object)
      @car_object = car_object

      @angle = 0.0
    end

    def update
      calculate
    end

    def calculate
      _x = @car_object.speed * Math.cos((90.0 + @car_object.angle) * Math::PI / 180)
      _y = @car_object.speed * Math.sin((90.0 + @car_object.angle) * Math::PI / 180)
      @car_object.x -= _x
      @car_object.y -= _y
    end
  end
end
