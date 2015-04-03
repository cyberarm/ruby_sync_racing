class Scene
  class Game < Chingu::GameState
    def setup
      Car.create(x: $window.width/2, y: $window.height/2, spec: "data/cars/test_car.json")
    end

    def draw
      super
      fill(Gosu::Color::GREEN)
    end
  end
end
