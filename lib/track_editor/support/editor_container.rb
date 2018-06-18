class Track
  class Editor
    Button  = Struct.new(:text, :image, :x, :y, :width, :block, :tooltip)
    Label   = Struct.new(:text, :x, :y)
    EditLine= Struct.new(:text, :password, :x, :y, :input)

    class EditorContainer < GameState
      Selector = Struct.new(:name, :text, :instance, :color, :selected)
      BoundingBox = Struct.new(:x, :y, :width, :height)

      def self.instance
        @instance
      end

      def self.instance=(i)
        @instance = i
      end

      attr_accessor :active_selector, :background, :save_file

      attr_reader :tiles, :decorations, :checkpoints, :starting_positions
      attr_reader :active_area, :screen_vector, :selectors_height, :tile_size
      attr_reader :click_sound, :error_sound
      def setup
        EditorContainer.instance = self
        @screen_vector = Vector2D.new(0, 0)
        @selectors_height = 50

        @mode_selectors = []
        @tile_size = 64
        @tiles = []
        @decorations = []
        @checkpoints = []
        @starting_positions = []

        @save_file = nil

        @click_sound = sample("assets/track_editor/click.ogg")
        @error_sound = sample("assets/track_editor/error.ogg")

        @background = Gosu::Color.rgba(100, 254, 78, 144)
        @active_area = BoundingBox.new(0, @selectors_height, $window.width, $window.height) # set x position dynamically

        prepare

        @active_selector = @mode_selectors.first
        @active_selector.instance = @mode_selectors.first.instance
        @active_selector.selected = true

        @tab_width = $window.width.to_f/@mode_selectors.count

        @mode_selectors.each do |s|
          if s.text.width > @tab_width
            until(s.text.width <= @tab_width)
              text = s.text.text.gsub(".", "")
              text = text[0...text.length-1]
              s.text.text = text+"..."
              puts s.text.text
            end
          end
        end

      end

      def prepare
      end

      def selector(name, instance, color = Gosu::Color.rgb(rand(200), rand(200), rand(200)), selected = false)
        text = Game::Text.new(name, size: 36, y: 10)
        @mode_selectors << Selector.new(name, text, instance, color, selected)
      end

      def draw_mode_selectors
        $window.fill_rect(0, 0, $window.width, @selectors_height, Gosu::Color.rgb(0,0,150))
        @mode_selectors.each_with_index do |s, i|
          s.text.x = (@tab_width*i)-(s.text.width/2)+@tab_width/2
          if mouse_over?(@tab_width*i, 0, @tab_width, @selectors_height) && s.instance
            $window.fill_rect(@tab_width*i, 0, @tab_width, @selectors_height, lighten(s.color))
            $window.fill_rect(@tab_width*i, 45, @tab_width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            $window.fill_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          else
            $window.fill_rect(@tab_width*i, 0, @tab_width, @selectors_height, s.color)
            $window.fill_rect(@tab_width*i, 45, @tab_width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            $window.fill_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          end

          $window.fill_rect(@tab_width*(i+1), 0, 2, @selectors_height, Gosu::Color::BLACK, 4)
          $window.fill_rect(0, 44, $window.width, 1, Gosu::Color::BLACK, 4)
          s.text.draw
        end
      end

      def draw_map
        Gosu.clip_to(@active_area.x, @active_area.y, @active_area.width, @active_area.height) do
          $window.fill_rect(@active_area.x, @active_area.y, @active_area.width, @active_area.height, @background, -10)

          Gosu.translate(@screen_vector.x, @screen_vector.y) do
            @tiles.each do |tile|
              image(tile.image).draw_rot(tile.x, tile.y, tile.z, tile.angle)
            end

            @decorations.each do |decoration|
              decoration.draw
            end

            @checkpoints.each do |checkpoint|
            end

            @starting_positions.each do |starting_position|
            end
          end
        end
      end

      def lighten(color, amount = 25)
        if defined?(color.alpha)
          return Gosu::Color.rgba(color.red+amount, color.green+amount, color.blue+amount, color.alpha)
        else
          return Gosu::Color.rgb(color.red+amount, color.green+amount, color.blue+amount)
        end
      end

      def darken(color, amount = 25)
        if defined?(color.alpha)
          return Gosu::Color.rgba(color.red-amount, color.green-amount, color.blue-amount, color.alpha)
        else
          return Gosu::Color.rgb(color.red-amount, color.green-amount, color.blue-amount)
        end
      end

      def draw
        # Container selection buttons
        draw_mode_selectors

        @active_selector.instance.draw if @active_selector && @active_selector.instance

        draw_map
      end

      def update
        @active_area.x = @active_selector.instance.sidebar.widest_element if @active_selector && @active_selector.instance

        @active_selector.instance.update if @active_selector && @active_selector.instance

        update_map_offset
        @screen_vector.x = 0 if @screen_vector.x > 0
        @screen_vector.y = 0 if @screen_vector.y > 0

      end

      def button_up(id)
        close_dialog {push_game_state(Track::Editor::Menu)} if id == Gosu::KbEscape

        case id
        when Gosu::MsLeft
          width = $window.width.to_f/@mode_selectors.count
          @mode_selectors.each_with_index do |s, i|
            if mouse_over?(width*i, 0, width, @selectors_height)
              if s.instance
                @active_selector = s
                # @active_selector.instance = s.klass.new unless s.instance.is_a?(s.klass)
                @active_selector.selected = true
                @active_selector.instance.focused
              end
            end
          end
        end

        @active_selector.instance.button_up(id) if @active_selector
      end

      def close_dialog(&block)
        window(:confirm, "Are you sure?", "Any unsaved changes will be lost!") { block.call }
      end

      def normalize_map_position(number)
        return (Integer((number/@tile_size).to_f.round(1).to_s.split('.').first))*@tile_size
      end

      def update_map_offset(sensitivity = 3, speed = Gosu.fps/2)
        if $window.mouse_x.between?($window.width-sensitivity, $window.width)
          @screen_vector.x-=speed
        elsif $window.mouse_x.between?(0, 0+sensitivity)
          @screen_vector.x+=speed
        end

        if $window.button_down?(Gosu::KbRight)
          @screen_vector.x-=speed
        end
        if $window.button_down?(Gosu::KbLeft)
          @screen_vector.x+=speed
        end

        if $window.mouse_y.between?($window.height-sensitivity, $window.height)
          @screen_vector.y-=speed
        end
        if $window.mouse_y.between?(0, 0+sensitivity)
          @screen_vector.y+=speed
        end

        if $window.button_down?(Gosu::KbUp)
          @screen_vector.y+=speed
        end
        if $window.button_down?(Gosu::KbDown)
          @screen_vector.y-=speed
        end
      end

      def save_track
        push_game_state(Save, edit_state: self, tiles: @tiles, decorations: @decorations, checkpoints: @checkpoints, starting_positions: @starting_positions)
      end

      # Has the track been changed since last save?
      def track_save_tainted?
        true
      end

      def window(type, title, caption, callback = nil, &block)
        _window = EditorWindow.new(type: type, title: title, caption: caption, callback: callback, block: block, editor: self)
        push_game_state(_window)
      end

      def add_message(string);end

      def mouse_in?(bounding_box)
        if $window.mouse_x.between?(bounding_box.x, bounding_box.x+bounding_box.width)
          if $window.mouse_y.between?(bounding_box.y, bounding_box.y+bounding_box.height)
            true
          else
            false
          end
        else
          false
        end
      end

      def mouse_over?(x, y, width, height)
        if $window.mouse_x.between?(x+1, x-1+width)
          if $window.mouse_y.between?(y, y-1+height)
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