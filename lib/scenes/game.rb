class Scene
  class Game < Chingu::GameState
    def setup
      Car.create(x: $window.width/2, y: $window.height/2, spec: "data/cars/test_car.json")
      Track.create(spec: "data/tracks/test_track.json")
    end

    def draw
      super
      fill(Gosu::Color.rgba(100,254,78,144))
    end
  end
end
