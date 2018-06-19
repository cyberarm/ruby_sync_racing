module Game
  class Scene
    class CarSelection < Menu
      def prepare
        title("Ruby Sync Racing")
        label("Choose Car", size: 50)
        button("← Track Selection") {push_game_state(LevelSelection)}
        label("", size: 25)

        @cars = Dir.glob("data/cars/*.json")
        @car_list = []
        @list_index = 0
        process_cars

        @color_options = [Gosu::Color::RED, Gosu::Color::GREEN, Gosu::Color::BLUE, Gosu::Color::BLACK]
        @multiline_text = MultiLineText.new("0\n1\n2\n", x: $window.width/2, y: 280, size: 18)
      end

      def process_cars
        @cars.each do |car|
          data = AbstractJSON.load(File.open(car).read)
          hash = {}
          hash[:data]        = data
          hash[:json]        = car
          hash[:image]       = image(AssetManager.image_from_id(data["spec"]["image"]))
          hash[:body_image]  = image(AssetManager.image_from_id(data["spec"]["body_image"]))
          hash[:color]       = Gosu::Color::WHITE
          hash[:top_speed]   = data["spec"]["top_speed"]
          hash[:break_speed] = data["spec"]["break_speed"]
          hash[:drag]        = data["spec"]["drag"]
          hash[:scale]       = data["spec"]["scale"]
          @car_list << hash
        end
      end

      def draw
        super
        Gosu.draw_rect($window.width/2-100, 280, 200, 64+15, Gosu::Color.rgb(50,50,100))
        list = @car_list[@list_index]
        list[:image].draw($window.width/2-85, 290, 3, list[:scale], list[:scale])
        list[:body_image].draw($window.width/2-85, 290, 3, list[:scale], list[:scale], list[:color])
        @multiline_text.draw

        @color_options.each_with_index do |color, i|
          Gosu.draw_rect($window.width/2-100+(i*20), 280+64+15, 20, 20, color)
        end
      end

      def update
        super
        list = @car_list[@list_index]

        @multiline_text.text = "Speed: #{list[:top_speed]}\nBrake: #{list[:break_speed]}\nDrag: #{list[:drag]}\n"
      end

      def mouse_over?
        if $window.mouse_x.between?($window.width/2-100, $window.width/2-100+200)
          if $window.mouse_y.between?(280, 280+64+15)
            true
          end
        end
      end

      def continue_to_game
        list = @car_list[@list_index]
        push_game_state(Play.new(trackfile: @options[:trackfile], carfile: list[:json]))
      end

      def button_up(id)
        super
        case id
        when Gosu::MsLeft
          if mouse_over?
            continue_to_game
          end
        when Gosu::KbReturn
          continue_to_game
        when Gosu::KbEnter
          continue_to_game
        when Gosu::KbLeft
          @list_index-=1
          if @list_index < 0
            @list_index = @car_list.count-1
          end
        when Gosu::KbRight
          @list_index+=1
          if @list_index > @car_list.count-1
            @list_index = 0
          end
        end
      end
    end
  end
end