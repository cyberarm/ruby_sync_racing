module Game
  class Scene
    class CarSelection < Menu
      def prepare
        title("Ruby Sync Racing")
        label("Choose Car", size: 50)
        button("← Track Selection") {push_game_state(LevelSelection)}
        label("", size: 25)

        @card_box = Track::Editor::EditorContainer::BoundingBox.new($window.width/2-100, 280, 200, 64+15)
        @cars = Dir.glob("data/cars/*.json")
        @car_list = []
        @list_index = 0
        process_cars

        @color_options = [
          Gosu::Color::WHITE,
          darken(Gosu::Color::WHITE),
          lighten(Gosu::Color::RED),
          Gosu::Color::RED,
          darken(Gosu::Color::RED),
          lighten(Gosu::Color.rgb(255,144,0)), # ORANGE
          Gosu::Color.rgb(255,144,0), # ORANGE
          darken(Gosu::Color.rgb(255,144,0)), # ORANGE
          lighten(Gosu::Color::GREEN),
          Gosu::Color::GREEN,
          darken(Gosu::Color::GREEN),
          lighten(Gosu::Color::BLUE),
          Gosu::Color::BLUE,
          darken(Gosu::Color::BLUE),
          lighten(Gosu::Color::GRAY),
          Gosu::Color::GRAY,
          darken(Gosu::Color::GRAY),
          lighten(Gosu::Color::BLACK),
          Gosu::Color::BLACK
        ]

        @active_color = @color_options.first
        @hover_color = nil
        @multiline_text = MultiLineText.new("0\n1\n2\n3\n", x: @card_box.x+(@card_box.width/2)-24, y: @card_box.y-10, size: 18)
      end

      def process_cars
        @cars.each do |car|
          data = AbstractJSON.load(File.open(car).read)
          hash = {}
          hash[:data]        = data
          hash[:json]        = car
          hash[:image]       = image(AssetManager.image_from_id(data["spec"]["image"]))
          hash[:body_image]  = image(AssetManager.image_from_id(data["spec"]["body_image"]))
          hash[:top_speed]   = data["spec"]["top_speed"]
          hash[:brake_speed] = data["spec"]["brake_speed"]
          hash[:acceleration]= data["spec"]["acceleration"]
          hash[:drag]        = data["spec"]["drag"]
          hash[:scale]       = data["spec"]["scale"]
          @car_list << hash
        end
      end

      def draw
        super
        if mouse_over_card?
          Gosu.draw_rect(@card_box.x, @card_box.y, @card_box.width, @card_box.height, Gosu::Color.rgba(56,45,89,212))
        else
          Gosu.draw_rect(@card_box.x, @card_box.y, @card_box.width, @card_box.height, Gosu::Color.rgba(0,45,89,212))
        end
        list = @car_list[@list_index]
        list[:image].draw(@card_box.x+15, @card_box.y+10, 3, list[:scale], list[:scale])
        if @hover_color
          list[:body_image].draw(@card_box.x+15, @card_box.y+10, 3, list[:scale], list[:scale], @hover_color)
        else
          list[:body_image].draw(@card_box.x+15, @card_box.y+10, 3, list[:scale], list[:scale], @active_color)
        end
        @multiline_text.draw

        @color_options.each_with_index do |color, i|
          if mouse_over_color?(i)
            if color.value > 0.5
              Gosu.draw_rect(@card_box.x+(i*20), @card_box.y+@card_box.height, 20, 20, darken(color, 50))
            else
              Gosu.draw_rect(@card_box.x+(i*20), @card_box.y+@card_box.height, 20, 20, lighten(color, 50))
            end
          else
            Gosu.draw_rect(@card_box.x+(i*20), @card_box.y+@card_box.height, 20, 20, color)
          end
        end
      end

      def update
        super
        list = @car_list[@list_index]

        found_color = false
        @color_options.each_with_index do |color, i|
          if mouse_over_color?(i)
            puts "Found: #{i}"
            found_color = true
            @hover_color = color
            break
          end
        end
        @hover_color = nil unless found_color

        @multiline_text.text = "Speed: #{list[:top_speed]}\nBrake: #{list[:brake_speed]}\nAcceleration: #{list[:acceleration]}\nDrag: #{list[:drag]}\n"
      end

      def mouse_over_card?
        if $window.mouse_x.between?(@card_box.x, @card_box.x+@card_box.width)
          if $window.mouse_y.between?(@card_box.y, @card_box.y+@card_box.height)
            true
          end
        end
      end

      def mouse_over_color?(i)
        if $window.mouse_x.between?(@card_box.x+(i*20), @card_box.x+(i*20)+20)
          if $window.mouse_y.between?(@card_box.y+@card_box.height, @card_box.y+@card_box.height+20)
            true
          end
        end
      end

      def continue_to_game
        list = @car_list[@list_index]
        push_game_state(Play.new(trackfile: @options[:trackfile], carfile: list[:json], body_color: @active_color))
      end

      def button_up(id)
        super
        case id
        when Gosu::MsLeft
          if mouse_over_card?
            continue_to_game
          else
            @color_options.each_with_index do |color, i|
              if mouse_over_color?(i)
                @active_color = color
                break
              end
            end
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