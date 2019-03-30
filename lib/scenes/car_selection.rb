module Game
  class Scene
    class CarSelection < Menu
      def prepare
        title("Ruby Sync Racing")
        label("Choose Car", size: 50)
        button("← Track Selection") {push_state(LevelSelection)}
        label("", size: 25)

        @card_box        = Track::Editor::EditorContainer::BoundingBox.new($window.width/2-150, 280, 300, 128+15)
        @left_arrow_box  = Track::Editor::EditorContainer::BoundingBox.new(@card_box.x-64, @card_box.y, 32, @card_box.height)
        @right_arrow_box = Track::Editor::EditorContainer::BoundingBox.new(@card_box.x+@card_box.width+32, @card_box.y, 32, @card_box.height)

        @left_arrow  = Text.new("◄", y: @left_arrow_box.y+@left_arrow_box.height/2, size: 32)
        @left_arrow.x = (@left_arrow_box.x-(@left_arrow_box.width/2)+(@left_arrow.width/2))
        @right_arrow = Text.new("►", y: @right_arrow_box.y+@right_arrow_box.height/2, size: 32)
        @right_arrow.x = (@right_arrow_box.x+(@right_arrow_box.width/2)-(@right_arrow.width/2))

        @button_hover_color = Gosu::Color.rgba(56,45,89,212)
        @button_color       = Gosu::Color.rgba(0,45,89,212)

        @boxes = [@card_box, @left_arrow_box, @right_arrow_box]

        @cars = Dir.glob("data/cars/*.json")
        @car_list = []
        @list_index = 0
        process_cars

        colors = [
          Gosu::Color.rgb(230,230,230), # WHITE
          Gosu::Color.rgb(230,0,0),     # RED
          Gosu::Color.rgb(230,144,0),   # ORANGE
          Gosu::Color.rgb(0,230,0),     # GREEN
          Gosu::Color.rgb(175, 0, 175), # PURPLE
          Gosu::Color.rgb(0, 0, 230),   # BLUE
          Gosu::Color.rgb(25, 25, 25)   # BLACK
        ]
        @color_options = []
        populate_color_options(colors)
        @colors_width = @color_options.size*20

        @active_color = @color_options.first
        @hover_color = nil
        @multiline_text = MultiLineText.new("", x: @card_box.x+(@card_box.width/2)-24, y: @card_box.y-10, size: 18)
      end

      def populate_color_options(colors)
        colors.each do |color|
          @color_options << lighten(color)
          @color_options << color
          @color_options << darken(color)
        end
      end

      def process_cars
        @cars.each do |car|
          data = AbstractJSON.load(File.read(car))
          hash = {}
          hash[:data]        = data
          hash[:json]        = car
          hash[:image]       = get_image(AssetManager.image_from_id(data["spec"]["image"]))
          hash[:body_image]  = get_image(AssetManager.image_from_id(data["spec"]["body_image"]))
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
        @boxes.each do |box|
          if mouse_in?(box)
            Gosu.draw_rect(box.x, box.y, box.width, box.height, @button_hover_color)
          else
            Gosu.draw_rect(box.x, box.y, box.width, box.height, @button_color)
          end
        end
        @left_arrow.draw
        @right_arrow.draw

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
              Gosu.draw_rect(@card_box.x+(@card_box.width/2)+(i*20)-(@colors_width/2), @card_box.y+@card_box.height+32, 20, 20, darken(color, 50))
            else
              Gosu.draw_rect(@card_box.x+(@card_box.width/2)+(i*20)-(@colors_width/2), @card_box.y+@card_box.height+32, 20, 20, lighten(color, 50))
            end
          else
            Gosu.draw_rect(@card_box.x+(@card_box.width/2)+(i*20)-(@colors_width/2), @card_box.y+@card_box.height+32, 20, 20, color)
          end
        end
      end

      def update
        super
        list = @car_list[@list_index]

        found_color = false
        @color_options.each_with_index do |color, i|
          if mouse_over_color?(i)
            found_color = true
            @hover_color = color
            break
          end
        end
        @hover_color = nil unless found_color

        @multiline_text.text = "Speed: #{list[:top_speed]}\nBrake: #{list[:brake_speed]}\nAcceleration: #{list[:acceleration]}\nDrag: #{list[:drag]}\n"
      end

      def mouse_in?(bounding_box)
        if $window.mouse_x.between?(bounding_box.x, bounding_box.x+bounding_box.width)
          if $window.mouse_y.between?(bounding_box.y, bounding_box.y+bounding_box.height)
            true
          end
        end
      end

      def mouse_over_color?(i)
        if $window.mouse_x.between?(@card_box.x+(@card_box.width/2)+(i*20)-(@colors_width/2), @card_box.x+(@card_box.width/2)+(i*20)-(@colors_width/2)+20)
          if $window.mouse_y.between?(@card_box.y+@card_box.height+32, @card_box.y+@card_box.height+32+20)
            true
          end
        end
      end

      def continue_to_game
        list = @car_list[@list_index]
        push_state(Play.new(trackfile: @options[:trackfile], carfile: list[:json], body_color: @active_color))
      end

      def button_up(id)
        super
        case id
        when Gosu::MsLeft
          if mouse_in?(@card_box)
            continue_to_game
          elsif mouse_in?(@left_arrow_box)
            @list_index-=1
            if @list_index < 0
              @list_index = @car_list.count-1
            end
          elsif mouse_in?(@right_arrow_box)
            @list_index+=1
            if @list_index > @car_list.count-1
              @list_index = 0
            end
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