module Game
  Button = Struct.new(:text, :rect, :background_color, :proc)
  class Scene
    class Menu < Chingu::GameState
      def setup
        $window.show_cursor = true

        @elements = []
        @background = Gosu::Color.rgba(45,45,76,89)
        @y = 20
        @z = -5

        prepare if defined?(self.prepare)
      end

      def draw
        super
        fill(@background, @z)
        @elements.each do |e|
          if e.is_a?(Game::Text)
            e.draw
          elsif e.is_a?(Game::Button)
            e.text.draw
            fill_rect(e.rect, e.background_color)
            if $window.mouse_x.between?(e.text.x-10, e.text.x+e.text.width+10)
              if $window.mouse_y.between?(e.text.y-10, e.text.y+e.text.height+10)
                fill_rect(e.rect, Gosu::Color.rgba(56,45,89,212))
              end
            end
          end
        end
      end

      def update
        super
      end

      def background(color, z = -5)
        raise "Color must be a Gosu::Color" unless color.is_a?(Gosu::Color)
        @background = color
        @z = z if z.is_a?(Integer)
      end

      def title(string)
        text = Game::Text.new(string, y: @y, size: 80)
        text.x = $window.width/2-text.width/2

        @elements.push(text)
        @y+=(text.height/3)+text.height
      end

      def label(string, options={}, proc = nil)
        # {y: @y, size: 26}
        options[:y] ||= @y
        options[:size] ||= 26

        text = Game::Text.new(string, options)
        text.x = $window.width/2-text.width/2

        @elements.push(text)
        @y+=(text.height*2)
      end

      def button(string, &block)
        text   = Game::Text.new(string, y: @y, size: 26)
        text.x = $window.width/2-text.width/2
        x = text.x-10
        y = text.y-10
        width  = text.width+20
        height = text.height+20

        button = Game::Button.new
        button.text = text
        button.rect = [x,y, width,height]
        button.background_color = Gosu::Color.rgba(0,45,89,212)
        button.proc = block

        @elements.push(button)
        @y+=(height/2)+height
      end

      def button_up(id)
        case id
        when Gosu::MsLeft
          @elements.each do |e|
            next unless e.is_a?(Game::Button)
            if $window.mouse_x.between?(e.text.x-10, e.text.x+e.text.width+10)
              if $window.mouse_y.between?(e.text.y-10, e.text.y+e.text.height+10)
                e.proc.call if e.proc.is_a?(Proc)
              end
            end
          end
        end
      end
    end
  end
end
