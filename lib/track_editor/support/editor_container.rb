class Track
  class Editor
    class EditorContainer < GameState
      Selector = Struct.new(:name, :text, :instance, :color, :selected)

      def self.instance
        @instance
      end

      def self.instance=(i)
        @instance = i
      end

      attr_accessor :active_selector
      def setup
        EditorContainer.instance = self

        @mode_selectors = []

        prepare
      end

      def prepare
      end

      def selector(name, instance, color = Gosu::Color.rgb(rand(200), rand(200), rand(200)), selected = false)
        text = Game::Text.new(name, size: 36, y: 10)
        @mode_selectors << Selector.new(name, text, instance, color, selected)
      end

      def draw_mode_selectors
        $window.fill_rect(0, 0, $window.width, 50, Gosu::Color.rgb(0,0,150))
        width = $window.width.to_f/@mode_selectors.count
        @mode_selectors.each_with_index do |s, i|
          s.text.x = (width*i)-(s.text.width/2)+width/2
          if mouse_over?(width*i, 0, width, 50)
            $window.fill_rect(width*i, 0, width, 50, lighten(s.color))
            $window.fill_rect(width*i, 45, width, 5, darken(s.color), 5) if s == @active_selector
            $window.fill_rect(width*i, 45, width, 1, Gosu::Color::BLACK, 5) if s == @active_selector
          else
            $window.fill_rect(width*i, 0, width, 50, s.color)
            $window.fill_rect(width*i, 45, width, 5, darken(s.color), 5) if s == @active_selector
            $window.fill_rect(width*i, 45, width, 1, Gosu::Color::BLACK, 5) if s == @active_selector
          end
          $window.fill_rect(width*(i+1), 0, 2, 50, Gosu::Color::BLACK, 10)
          s.text.draw
        end
      end

      def lighten(color, amount = 25)
        return Gosu::Color.rgb(color.red+amount, color.green+amount, color.blue+amount)
      end

      def darken(color, amount = 25)
        return Gosu::Color.rgb(color.red-amount, color.green-amount, color.blue-amount)
      end

      def draw
        # Container selection buttons
        draw_mode_selectors

        @active_selector.instance.draw if @active_selector && @active_selector
      end

      def update
        @active_selector.instance.update if @active_selector && @active_selector
      end

      def button_up(id)
        $window.close if id == Gosu::KbEscape

        case id
        when Gosu::MsLeft
          width = $window.width.to_f/@mode_selectors.count
          @mode_selectors.each_with_index do |s, i|
            if mouse_over?(width*i, 0, width, 50)
              @active_selector = s
              @active_selector.selected = true
            end
          end
        end

        @active_selector.instance.button_up(id) if @active_selector && @active_selector.respond_to?(:button_up)
      end

      def mouse_over?(x, y, width, height)
        if $window.mouse_x.between?(x+1, x-1+width)
          if $window.mouse_y.between?(y+1, y-1+height)
            true
          else
            false
          end
        else
          false
        end
      end
    end
  end
end