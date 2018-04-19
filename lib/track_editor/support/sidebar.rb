class Track
  class Editor
    class Sidebar
      PADDING = 5

      attr_reader :widest_element
      def initialize(parent)
        @editor = EditorContainer.instance
        @parent = parent
        @elements = []
        @widest_element = 100
        @relative_y = @editor.selectors_height+PADDING

        @tooltip = Game::Text.new("", size: 24)

        if @editor.active_selector.color.value < 0.3
          @background_color = @editor.lighten(@editor.active_selector.color, 50)
          @hover_background_color = @editor.lighten(@background_color)
          @active_background_color = @editor.lighten(@hover_background_color)
        else
          @background_color = @editor.darken(@editor.active_selector.color, 50)
          @hover_background_color = @editor.darken(@background_color)
          @active_background_color = @editor.darken(@hover_background_color)
        end
      end

      def draw
        $window.fill_rect(0, 50, @widest_element, $window.height-50, @editor.darken(@editor.active_selector.color))
        @elements.each do |element|
          if element.is_a?(Button)
            if element.text
              if @editor.mouse_over?(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2))
                show_tooltip(element)
                if $window.button_down?(Gosu::MsLeft)
                  $window.fill_rect(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2), @active_background_color)
                else
                  $window.fill_rect(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2), @hover_background_color)
                end
              else
                $window.fill_rect(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2), @background_color)
              end
              element.text.draw
            elsif element.image
              if @editor.mouse_over?(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2))
                show_tooltip(element)
                if $window.button_down?(Gosu::MsLeft)
                  $window.fill_rect(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2), @active_background_color)
                else
                  $window.fill_rect(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2), @hover_background_color)
                end
              else
                $window.fill_rect(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2), @background_color)
              end
              element.image.draw(element.x, element.y,10)
            end
          elsif element.is_a?(Label)
              element.text.x = @widest_element - (@widest_element/2)-(element.text.width/2)
            element.text.draw
          end
        end
      end

      def show_tooltip(element)
        if element.tooltip
          @tooltip.text = element.tooltip.split(/-|_/).map(&:capitalize).join(" ")
          @tooltip.x = @widest_element+PADDING
          if element.image
            @tooltip.y = element.y+(element.image.height/2)-(@tooltip.height/2)
          else
            @tooltip.y = element.y+(element.text.height/2)-(@tooltip.height/2)
          end

          $window.fill_rect(@tooltip.x-PADDING, @tooltip.y-PADDING, @tooltip.width+(PADDING*2), @tooltip.height+(PADDING*2), @editor.darken(@editor.active_selector.color), 10)
          @tooltip.draw
        end
      end

      def update
        # @elements.each do |element|
        #   if element.is_a?(Button)
        #     if element.text && @editor.mouse_over?(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2))
        #       show_tooltip(element.tooltip)
        #     elsif element.image && @editor.mouse_over?(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2))
        #       show_tooltip(element.tooltip)
        #     end
        #   end
        # end
      end

      def button_up(id)
        case id
        when Gosu::MsLeft
          @elements.each do |element|
            if element.is_a?(Button)
              if element.text
                if @editor.mouse_over?(element.x-(element.width/2-element.text.width/2), element.y-PADDING, element.width, element.text.height+(PADDING*2))
                  @editor.click_sound.play
                  element.block.call if element.block
                end
              elsif element.image
                if @editor.mouse_over?(element.x-(element.width/2-element.image.width/2), element.y-PADDING, element.width, element.image.height+(PADDING*2))
                  @editor.click_sound.play
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

      def add_button(text_or_image, tooltip, block = nil)
        if text_or_image.is_a?(Gosu::Image)
          @elements << Button.new(nil, text_or_image, 15, relative_y(text_or_image.height), 0, block, tooltip)
        else
          text = Game::Text.new(text_or_image, size: 24, x: 15)
          @elements << Button.new(text, nil, 15, relative_y(text.height), 0, block, tooltip)
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
        @widest_element = widest
      end
    end
  end
end