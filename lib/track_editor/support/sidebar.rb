class Track
  class Editor
    class Sidebar
      PADDING = 5
      BACKGROUND = Gosu::Color.rgb(45,45,76)
      HOVER_BACKGROUND = Gosu::Color.rgb(56,45,89)

      def initialize
        @elements = []
        @widest_sidebar_element = 100
        @relative_y = 50
      end

      def draw
        $window.fill_rect(0, 50, @widest_sidebar_element, $window.height-50, EditorContainer.instance.darken(EditorContainer.instance.active_selector.color))
        @elements.each do |element|
          if element.is_a?(Button)
            if element.text
              if EditorContainer.instance.mouse_over?(element.x-PADDING, element.y-PADDING, element.text.width+(PADDING*2), element.text.height+(PADDING*2))
                $window.fill_rect(element.x-PADDING, element.y-PADDING, element.text.width+(PADDING*2), element.text.height+(PADDING*2), HOVER_BACKGROUND)
              else
                $window.fill_rect(element.x-PADDING, element.y-PADDING, element.text.width+(PADDING*2), element.text.height+(PADDING*2), BACKGROUND)
              end
              element.text.draw
            elsif element.image
              if EditorContainer.instance.mouse_over?(element.x-PADDING, element.y-PADDING, element.image.width+(PADDING*2), element.image.height+(PADDING*2))
                $window.fill_rect(element.x-PADDING, element.y-PADDING, element.image.width+(PADDING*2), element.image.height+(PADDING*2), HOVER_BACKGROUND)
              else
                $window.fill_rect(element.x-PADDING, element.y-PADDING, element.image.width+(PADDING*2), element.image.height+(PADDING*2), BACKGROUND)
              end
              element.image.draw(element.x,element.y,10)
            end
          elsif element.is_a?(Label)
            element.text.draw
          end
        end
      end

      def update
      end

      def button_up(id)
      end

      def relative_y(height)
        return @relative_y if @elements.size == 0
        return @elements.last.y+@elements.last.text.height+(PADDING*4) if defined?(@elements.last.text) && @elements.last.text
        return @elements.last.y+@elements.last.image.height+(PADDING*4) if defined?(@elements.last.image) && @elements.last.image
      end

      def add_button(text_or_image, block = nil)
        if text_or_image.is_a?(Gosu::Image)
          @elements << Button.new(nil, text_or_image, 15, relative_y(text_or_image.height), block)
        else
          text = Game::Text.new(text_or_image, size: 24, x: 15)
          @elements << Button.new(text, nil, 15, relative_y(text.height), block)
          text.y = @elements.last.y
        end

        calculate_widest_element
        return @elements.last
      end

      def add_label(string)
        text = Game::Text.new(string, size: 24, x: 15)
        text.y = relative_y(text.height)
        @elements << Label.new(text, 15, text.y)

        calculate_widest_element
        return @elements.last
      end

      def calculate_widest_element
        widest = 0
        @elements.each do |e|
          widest = e.text.width+e.x+e.x if defined?(e.text) && e.text != nil && e.text.width > widest
          widest = e.image.width+e.x+e.x if defined?(e.image) && e.image != nil && e.image.width > widest
        end

        @widest_sidebar_element = widest
      end
    end
  end
end