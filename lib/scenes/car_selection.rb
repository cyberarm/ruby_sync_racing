module Game
  class Scene
    class CarSelection < Menu
      def prepare
        # List cars graphically
        # with top speed, .. ..
        # push_game_state(Game)
        title("Ruby Sync Racing")
        label("Choose Car", size: 50)
        button("← Track Selection") {push_game_state(previous_game_state)}
        label("", size: 25)

        @cars = Dir.glob("data/cars/*.json")
        @car_list = []

        process_cars
      end

      def process_cars
        @cars.each_with_index do |car, i|
          _car = AbstractJSON.load(open(car).read)

          info = "Top speed: #{_car["spec"]["top_speed"]}, Break speed: #{_car["spec"]["break_speed"]}, Drag: #{_car["spec"]["drag"]}"

          button(_car["name"]) {
            push_game_state(Play.new(trackfile: options[:trackfile], carfile: @cars[i]))
          }
          label(info)
          label("", size: 15)
        end
      end

      # def draw
      #   super
      #   fill(Gosu::Color.rgba(45,45,76,89))
      #
      #   @car_list.each do |car|
      #     $window.fill_rect([car["text"].x-4,car["text"].y-4, car["text"].width+8, car["text"].height+4], Gosu::Color.rgba(0,0,0,200), 1)
      #
      #     if $window.mouse_x.between?(car["text"].x-4, car["text"].x+car["text"].width+8)
      #       if $window.mouse_y.between?(car["text"].y-4, car["text"].y+car["text"].height+4)
      #         $window.fill_rect([car["text"].x-4,car["text"].y-4, car["text"].width+8, car["text"].height+4], Gosu::Color::GRAY, 1)
      #       end
      #     end
      #
      #     car["text"].draw
      #     car["info"].draw
      #     car["image"].draw_rot(car["text"].x-30, car["text"].y-4, 2, -90, 1,1, car["spec"]["factor"], car["spec"]["factor"])
      #   end
      # end

      def button_up(id)
        super
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
