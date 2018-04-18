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
              if EditorContainer.instance.mouse_over?(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2))
                $window.fill_rect(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2), HOVER_BACKGROUND)
              else
                $window.fill_rect(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2), BACKGROUND)
              end
              element.text.draw
            elsif element.image
              if EditorContainer.instance.mouse_over?(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2))
                $window.fill_rect(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2), HOVER_BACKGROUND)
              else
                $window.fill_rect(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2), BACKGROUND)
              end
              element.image.draw(element.x, element.y,10)
            end
          elsif element.is_a?(Label)
              element.text.x = @widest_sidebar_element - (@widest_sidebar_element/2)-(element.text.width/2)
            element.text.draw
          end
        end
      end

      def update
      end

      def button_up(id)
        case id
        when Gosu::MsLeft
          @elements.each do |element|
            if element.is_a?(Button)
              if element.text
                if EditorContainer.instance.mouse_over?(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2))
                  element.block.call if element.block
                end
              elsif element.image
                if EditorContainer.instance.mouse_over?(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2))
                  element.block.call if element.block
                end
              end
            end
          end
        end
      end

      def relative_y(height)
        return @relative_y if @elements.size == 0
        return @elements.last.y+@elements.last.text.height+(PADDING*4) if defined?(@elements.last.text) && @elements.last.text
        return @elements.last.y+@elements.last.image.height+(PADDING*4) if defined?(@elements.last.image) && @elements.last.image
      end

      def add_button(text_or_image, block = nil)
        if text_or_image.is_a?(Gosu::Image)
          @elements << Button.new(nil, text_or_image, 15, relative_y(text_or_image.height), 0, block)
        else
          text = Game::Text.new(text_or_image, size: 24, x: 15)
          @elements << Button.new(text, nil, 15, relative_y(text.height), 0, block)
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
        widest_button = 0

        @elements.each do |e|
          widest = e.text.width+e.x+e.x if defined?(e.text) && e.text != nil && e.text.width > widest
          widest = e.image.width+e.x+e.x if defined?(e.image) && e.image != nil && e.image.width > widest

          widest_button = e.text.width+(PADDING+4) if e.is_a?(Button) && defined?(e.text) && e.text != nil && e.text.width > widest_button
          widest_button = e.image.width+(PADDING+4) if e.is_a?(Button) && defined?(e.image) && e.image != nil && e.image.width > widest_button
        end

        @elements.each do |e|
          if e.is_a?(Button)
            raise "widest_button is 0!" if widest_button <= 0 # Only raise if buttons exist.

            e.width = widest_button
            e.x = ((widest/2)-(e.text.width/2)) if e.text
            e.text.x = ((widest/2)-(e.text.width/2)) if e.text
            e.x = ((widest/2)-(e.image.width/2)) if e.image
          end
        end
        @widest_sidebar_element = widest
      end
    end
  end
end