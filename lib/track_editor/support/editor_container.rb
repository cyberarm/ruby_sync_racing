class Track
  class Editor
    Button = Struct.new(:text, :image, :x, :y, :width, :block)
    Label  = Struct.new(:text, :x, :y)

    class EditorContainer < GameState
      Selector = Struct.new(:name, :text, :klass, :color, :selected, :instance)

      def self.instance
        @instance
      end

      def self.instance=(i)
        @instance = i
      end

      attr_accessor :active_selector, :use_mouse_image
      attr_reader :tiles, :decorations, :checkpoints, :starting_positions
      attr_reader :mouse, :mouse_position
      def setup
        EditorContainer.instance = self

        @mode_selectors = []
        @tiles = []
        @decorations = []
        @checkpoints = []
        @starting_positions = []

        @use_mouse_image = true
        @mouse = nil
        @mouse_position = {x: 0, y: 0, angle: 0}

        @mouse_sound = sample("assets/track_editor/click.ogg")
        @error_sound = sample("assets/track_editor/error.ogg")

        prepare

        @active_selector = @mode_selectors.first
        @active_selector.instance = @mode_selectors.first.klass.new
        @active_selector.selected = true
      end

      def prepare
      end

      def selector(name, klass, color = Gosu::Color.rgb(rand(200), rand(200), rand(200)), selected = false)
        text = Game::Text.new(name, size: 36, y: 10)
        @mode_selectors << Selector.new(name, text, klass, color, selected)
      end

      def draw_mode_selectors
        $window.fill_rect(0, 0, $window.width, 50, Gosu::Color.rgb(0,0,150))
        width = $window.width.to_f/@mode_selectors.count
        @mode_selectors.each_with_index do |s, i|
          s.text.x = (width*i)-(s.text.width/2)+width/2
          if mouse_over?(width*i, 0, width, 50)
            $window.fill_rect(width*i, 0, width, 50, lighten(s.color))
            $window.fill_rect(width*i, 45, width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            $window.fill_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          else
            $window.fill_rect(width*i, 0, width, 50, s.color)
            $window.fill_rect(width*i, 45, width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            $window.fill_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          end

          $window.fill_rect(width*(i+1), 0, 2, 50, Gosu::Color::BLACK, 4)
          $window.fill_rect(0, 44, $window.width, 1, Gosu::Color::BLACK, 4)
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

        @active_selector.instance.draw if @active_selector && @active_selector.instance

        @mouse.draw_rot(@mouse_position[:x], @mouse_position[:y], 0, @mouse_position[:angle]) if @mouse  && @use_mouse_image
      end

      def update
        @mouse_position[:x], @mouse_position[:y] = $window.mouse_x, $window.mouse_y

        @active_selector.instance.update if @active_selector && @active_selector.instance
      end

      def button_up(id)
        $window.close if id == Gosu::KbEscape

        case id
        when Gosu::MsLeft
          width = $window.width.to_f/@mode_selectors.count
          @mode_selectors.each_with_index do |s, i|
            if mouse_over?(width*i, 0, width, 50)
              @active_selector = s
              @active_selector.instance = s.klass.new unless s.instance.is_a?(s.klass)
              @active_selector.selected = true
            end
          end
        end

        @active_selector.instance.button_up(id) if @active_selector
      end

      def mouse_image(image)
        @mouse = image
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