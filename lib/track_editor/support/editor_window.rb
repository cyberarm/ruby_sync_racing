class Track
  class Editor
    class EditorWindow < CyberarmEngine::GameState
      def setup
        @type = options[:type]
        @title= options[:title]
        @caption = options[:caption]
        @callback= options[:callback]
        @block = options[:block]

        @previous_game_state = options[:editor]
        @editor = EditorContainer.instance

        @titlebar_height = 50
        @width  = 640
        @height = 480

        @elements = []
        @widest_element = 100
        @relative_x = $window.width/2-@width/2+(Sidebar::PADDING*2)
        @button_relative_x = $window.width/2+@width/2+(Sidebar::PADDING*2)
        @relative_y = $window.height/2-@height/2

        @base_color = Gosu::Color.rgba(100,100,100, 200)

        if @type == :custom
          # Do stuff
        end

        create_window

        @titlebar_color = @editor.darken(@base_color)
        @window_border_color = @editor.lighten(@base_color)
        @window_background_color = @editor.lighten(@base_color)
        @background_color = @editor.lighten(@base_color)
      end

      def create_window
        @title_text = Game::Text.new(@title, x: $window.width/2-@width/2+Sidebar::PADDING, size: 36)
        label(@caption, 32)

        self.send(@type)

        recalculate_element_y_positions
      end

      def draw
        @previous_game_state.draw
        $window.flush
        # BACKGROUND
        Gosu.draw_rect(0, 0, $window.width, $window.height, @background_color)#Gosu::Color.rgba(100, 100, 100, 200))
        # WINDOW BORDER
        Gosu.draw_rect($window.width/2-@width/2-Sidebar::PADDING, $window.height/2-@height/2-Sidebar::PADDING, @width+(Sidebar::PADDING*2), @height+(Sidebar::PADDING*2), @window_border_color)#Gosu::Color.rgba(25, 25, 25, 200))
        # WINDOW
        Gosu.draw_rect($window.width/2-@width/2, $window.height/2-@height/2, @width, @height, @window_background_color)#Gosu::Color.rgba(50, 50, 50, 200))
        # WINDOW TITLE BAR
        Gosu.draw_rect($window.width/2-@width/2, $window.height/2-@height/2, @width, @titlebar_height, @titlebar_color)#Gosu::Color.rgba(25, 25, 25, 200))
        @title_text.draw

        @elements.each do |element|
          if element.is_a?(Button)
            if @editor.mouse_over?(element.x-Sidebar::PADDING, element.y-Sidebar::PADDING, element.width+(Sidebar::PADDING*2), element.text.height+(Sidebar::PADDING*2))
              if $window.button_down?(Gosu::MsLeft)
                Gosu.draw_rect(element.x-Sidebar::PADDING, element.y-Sidebar::PADDING, element.width+(Sidebar::PADDING*2), element.text.height+(Sidebar::PADDING*2), @editor.darken(@base_color, 50), 10)
              else
                Gosu.draw_rect(element.x-Sidebar::PADDING, element.y-Sidebar::PADDING, element.width+(Sidebar::PADDING*2), element.text.height+(Sidebar::PADDING*2), @editor.darken(@base_color, 40), 10)
              end
            else
              Gosu.draw_rect(element.x-Sidebar::PADDING, element.y-Sidebar::PADDING, element.width+(Sidebar::PADDING*2), element.text.height+(Sidebar::PADDING*2), @editor.darken(@base_color), 10)
            end
            element.text.draw
          elsif element.is_a?(Label)
            element.text.draw
          elsif element.is_a?(EditLine)
          else
            element.draw if defined?(element.draw)
          end
        end
      end

      def update
      end

      def button_up(id)
        case id
        when Gosu::KbEscape
          close
        when Gosu::MsLeft
          @elements.each do |element|
            if element.is_a?(Button)
              if @editor.mouse_over?(element.x-Sidebar::PADDING, element.y-Sidebar::PADDING, element.width+(Sidebar::PADDING*2), element.text.height+(Sidebar::PADDING*2))
                element.block.call(self) if element.block
              end
            end
          end
        end
      end

      def recalculate_element_y_positions # and button x positions
        @title_text.x+=@width/2-@title_text.width/2
        @title_text.y = ($window.height/2-@height/2)+Sidebar::PADDING

        @relative_y = ($window.height/2-@height/2)+@titlebar_height+(Sidebar::PADDING*2)

        @elements.each_with_index do |element, index|
          if index > 0 && @elements[index-1].is_a?(Button) && !element.is_a?(Button)
            @button_relative_x = $window.width/2+@width/2+(Sidebar::PADDING*2)

            @relative_y+=@elements[index-1].text.height+(Sidebar::PADDING*3)
          end
          if element.is_a?(Button)
            if @button_relative_x+element.width > @relative_x+@width
              @button_relative_x-=element.width+(Sidebar::PADDING*4)
              element.text.x = @button_relative_x
            end

            element.text.x, element.x = @button_relative_x, @button_relative_x
            element.text.y, element.y = @relative_y, @relative_y

            @button_relative_x-=element.width+(Sidebar::PADDING*3)
          elsif element.is_a?(Label)
            element.text.y = @relative_y

            @relative_y+=element.text.height+Sidebar::PADDING
          elsif element.is_a?(EditLine)
          elsif element.is_a?(Game::Text)
            element.y = @relative_y

            @relative_y+=element.height
          end
        end
      end

      def close
        push_state(@previous_game_state)
      end

      # WINDOW TYPES
      def alert()
        button("Okay") do
          close
        end
      end

      def prompt
        input = edit_line ""
        button("Okay") do
          callback(input.text)
        end
        button("Cancel")
      end

      def confirm()
        @height = 200
        @base_color = Gosu::Color.rgba(100, 50, 0, 200)

        button("Cancel") do
          close
        end
        button("Okay") do
          @block.call(self) if @block
        end
      end

      # Elements
      def button(label, &block)
        text = Game::Text.new(label, x: @button_relative_x, y: @relative_y, z: 20, size: 30)
        @elements << Button.new(text, nil, @relative_x, @button_relative_y, text.width, block)
      end

      def label(string, size = 24)
        text = Game::Text.new(string, x: @relative_x, y: @relative_y, z: 20, size: size)
        @elements << Label.new(text, @relative_x, @relative_y)
      end

      def edit_line(text, password = false)
      end
    end
  end
end