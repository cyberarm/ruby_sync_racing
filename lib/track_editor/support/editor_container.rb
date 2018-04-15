class Track
  class Editor
    class EditorContainer < GameState
      Selector = Struct.new(:name, :text, :klass)

      def setup
        @mode_selectors = []
        @font = Gosu::Font.new(36)

        prepare
      end

      def prepare
      end

      def selector(name, klass)
        text = Game::Text.new(name, size: 36, y: 10)
        @mode_selectors << Selector.new(name, text, klass)
      end

      def draw_mode_selectors
        $window.fill_rect(0, 0, $window.width, 50, Gosu::Color.rgb(0,0,150))
        width = $window.width.to_f/@mode_selectors.count
        @mode_selectors.each_with_index do |s, i|
          s.text.x = (width*i)-(s.text.width/2)+width/2
          if mouse_over?(s.text)
            $window.fill_rect(width*i, 0, width, 50, Gosu::Color.rgb(0,0,50*(i+1)))
          else
            $window.fill_rect(width*i, 0, width, 50, Gosu::Color.rgb(0,0,25*(i+1)))
          end
          s.text.draw
        end
      end

      def draw
        # Container selection buttons
        draw_mode_selectors

        # Tile selection
        $window.fill_rect(0, 50, 80, $window.height-50, Gosu::Color.rgb(0,150,0))

        # Undefined? Properies Menu?
        $window.fill_rect(80, $window.height-100, $window.width-80, 100, Gosu::Color.rgb(50,0,0))
      end

      def update
      end

      def button_up(id)
        $window.close if id == Gosu::KbEscape
      end

      def mouse_over?(text_object)
        if $window.mouse_x.between?(text_object.x-20, text_object.x+text_object.width+20)
          if $window.mouse_y.between?(text_object.y-20, text_object.y+text_object.height+20)
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