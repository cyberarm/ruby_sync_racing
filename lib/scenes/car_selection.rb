module Game
  class Scene
    class CarSelection < Chingu::GameState
      def setup
        # List cars graphically
        # with top speed, .. ..
        # push_game_state(Game)
        @title = Game::Text.new("Ruby Sync Racing", x: $window.width/2, y: 20, color: Gosu::Color::WHITE, size: 80)
        @sub_title = Game::Text.new("Choose Car", x: $window.width/2, y: 120, color: Gosu::Color::WHITE, size: 50)
        @title.x = $window.width/2-@title.width/2
        @sub_title.x = $window.width/2-@sub_title.width/2

        @cars = Dir.glob("data/cars/*.json")
        @car_list = []

        process_cars
      end

      def process_cars
        y = 180

        @cars.each do |car|
          _car = MultiJson.load(open(car).read)
          image = Gosu::Image[_car["spec"]["image"]]
          text  = Game::Text.new(_car["name"], x: $window.width/3, y: y, size: 26)
          y+=30

          info  = Game::Text.new("Top speed: #{_car["spec"]["top_speed"]}, Break speed: #{_car["spec"]["break_speed"]}, Drag: #{_car["spec"]["drag"]}", x: $window.width/3, y: y, size: 26)
          _car["image"] = image
          _car["text"]  = text
          _car["info"]  = info

          @car_list << _car
          y+=40
        end
      end

      def draw
        super
        fill(Gosu::Color.rgba(45,45,76,89))
        @title.draw
        @sub_title.draw

        @car_list.each do |car|
          $window.fill_rect([car["text"].x-4,car["text"].y-4, car["text"].width+8, car["text"].height+4], Gosu::Color::GRAY, 1)

          if $window.mouse_x.between?(car["text"].x-4, car["text"].x+car["text"].width+8)
            if $window.mouse_y.between?(car["text"].y-4, car["text"].y+car["text"].height+4)
              $window.fill_rect([car["text"].x-4,car["text"].y-4, car["text"].width+8, car["text"].height+4], Gosu::Color.rgba(0,0,0,200), 1)
            end
          end

          car["text"].draw
          car["info"].draw
          car["image"].draw_rot(car["text"].x-30, car["text"].y-4, 2, -90, 1,1, car["spec"]["factor"], car["spec"]["factor"])
        end
      end

      def button_up(id)
        @car_list.each_with_index do |car, i|
          if $window.mouse_x.between?(car["text"].x-4, car["text"].x+car["text"].width+8)
            if $window.mouse_y.between?(car["text"].y-4, car["text"].y+car["text"].height+4)
              # Do Stuff
              push_game_state(Play.new(trackfile: options[:trackfile], carfile: @cars[i]))
            end
          end
        end
      end
    end
  end
end
