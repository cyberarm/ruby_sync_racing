class Track
  class Editor
    class Sidebar
      def initialize
        @elements = []
        @widest_sidebar_element = 100
      end

      def draw
        $window.fill_rect(0, 50, @widest_sidebar_element, $window.height-50, EditorContainer.instance.darken(EditorContainer.instance.active_selector.color))
        @elements.each do |element|

        end
      end

      def update
      end

      def button_up(id)
      end

      def add_button(text_or_image, block)
        EditorContainer.instance
      end

      def add_label(text)
      end
    end
  end
end