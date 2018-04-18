class Track
  class Editor
    class EditorMode

      attr_reader :sidebar
      def initialize
        @editor = EditorContainer.instance
        @sidebar = Sidebar.new

        setup if defined?(setup)
      end

      def draw
        @sidebar.draw
      end

      def update
        @sidebar.update
      end

      def button_up(id)
        @sidebar.button_up(id)
      end

      def sidebar_button(text_or_image, tooltip = nil, &block)
        @sidebar.add_button(text_or_image, tooltip, block)
      end

      def sidebar_label(text)
        @sidebar.add_label(text)
      end

      def properties
      end
    end
  end
end