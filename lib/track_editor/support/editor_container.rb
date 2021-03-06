class Track
  class Editor
    Button  = Struct.new(:text, :image, :x, :y, :width, :block, :tooltip)
    Label   = Struct.new(:text, :x, :y)
    EditLine= Struct.new(:text, :password, :x, :y, :input)

    class EditorContainer < CyberarmEngine::GameState
      Selector = Struct.new(:name, :text, :instance, :color, :selected)
      BoundingBox = Struct.new(:x, :y, :width, :height)
      EditorMessage=Struct.new(:text, :born, :time_to_live, :alpha)

      def self.instance
        @instance
      end

      def self.instance=(i)
        @instance = i
      end

      attr_accessor :active_selector, :background, :time_of_day, :save_file, :track_tainted

      attr_reader :tiles, :decorations, :checkpoints, :starting_positions
      attr_reader :active_area, :screen_vector, :selectors_height, :tab_width, :tile_size
      attr_reader :click_sound, :error_sound
      def setup
        EditorContainer.instance = self
        @track_tainted = false
        @editor_messages = []
        @screen_vector = CyberarmEngine::Vector.new(0, 0)
        @selectors_height = 50

        @mode_selectors = []
        @tile_size = 64
        @tiles = []
        @decorations = []
        @checkpoints = []
        @starting_positions = []

        @font = Gosu::Font.new(24, name: Gosu.default_font_name)

        @save_file = nil

        @click_sound = get_sample("assets/track_editor/click.ogg")
        @error_sound = get_sample("assets/track_editor/error.ogg")

        @active_area = BoundingBox.new(0, @selectors_height, window.width, window.height) # set x position dynamically
        @window_width = window.width
        @window_height = window.height
        @grid_color = Gosu::Color.rgb(50, 50, 50)

        prepare

        @background = @track_data ? Gosu::Color.rgba(@track_data["background"]["red"], @track_data["background"]["green"], @track_data["background"]["blue"], @track_data["background"]["alpha"]) : Gosu::Color.rgba(100, 254, 78, 144)
        @time_of_day = @track_data ? @track_data["time_of_day"] : "noon"

        @active_selector = @mode_selectors.first
        @active_selector.instance = @mode_selectors.first.instance
        @active_selector.selected = true

        resize_ui
      end

      def prepare
      end

      def starting_position_tile
        @_starting_position_tile ||= Gosu.record(@tile_size, @tile_size) do
          Gosu.draw_rect(0, 0, @tile_size, @tile_size, Gosu::Color.rgba(100,100,100,150), 3)
          (@tile_size/2).times do |n|
            Gosu.draw_rect(@tile_size/2-n, n, n+n, 1, Gosu::Color.rgba(200,50,50, 100), 3)
          end
          Gosu.draw_rect(@tile_size/4, @tile_size/2, @tile_size/2, @tile_size/2, Gosu::Color.rgba(200,50,50, 100), 3)
        end
      end

      def checkpoint_tile
        @_checkpoint_tile ||= Gosu.record(4, 4) do
          Gosu.draw_rect(0, 0, 4, 4, Gosu::Color.rgba(255, 255, 100, 255), 3)
        end
      end

      def selector(name, instance, color = Gosu::Color.rgb(rand(200), rand(200), rand(200)), selected = false)
        text = CyberarmEngine::Text.new(name, size: 36, y: 10)
        @mode_selectors << Selector.new(name, text, instance, color, selected)
      end

      def draw_mode_selectors
        draw_rect(0, 0, $window.width, @selectors_height, Gosu::Color.rgb(0,0,150))
        @mode_selectors.each_with_index do |s, i|
          s.text.x = (@tab_width*i)-(s.text.width/2)+@tab_width/2
          s.text.y = (@selectors_height/2)-s.text.height/2
          if mouse_over?(@tab_width*i, 0, @tab_width, @selectors_height) && s.instance
            draw_rect(@tab_width*i, 0, @tab_width, @selectors_height, lighten(s.color))
            draw_rect(@tab_width*i, 45, @tab_width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            draw_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          else
            draw_rect(@tab_width*i, 0, @tab_width, @selectors_height, s.color)
            draw_rect(@tab_width*i, 45, @tab_width, 1, Gosu::Color::BLACK, 5) if s == @active_selector

            draw_rect(0, 45, $window.width, 5, darken(s.color), 5) if s == @active_selector
          end

          draw_rect(@tab_width*(i+1), 0, 2, @selectors_height, Gosu::Color::BLACK, 4)
          draw_rect(0, 44, $window.width, 1, Gosu::Color::BLACK, 4)
          s.text.draw
        end
      end

      def draw_map
        Gosu.clip_to(@active_area.x, @active_area.y, @active_area.width, @active_area.height) do
          draw_rect(@active_area.x, @active_area.y, @active_area.width, @active_area.height, @background, -10)

          Gosu.translate(@screen_vector.x, @screen_vector.y) do
            @tiles.each do |tile|
              get_image(tile.image).draw_rot(tile.x, tile.y, tile.z, tile.angle)
            end

            @decorations.each do |decoration|
              get_image(decoration.image).draw_rot(decoration.x, decoration.y, decoration.z, decoration.angle, 0.5, 0.5, decoration.scale, decoration.scale)
            end

            @checkpoints.each do |checkpoint|
              draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(255, 255, 127, 75), 5)
            end

            @starting_positions.each_with_index do |starting_position, i|
              starting_position_tile.draw_rot(starting_position.x, starting_position.y, 3, starting_position.angle, 0.5, 0.5)
              @font.draw_text("#{i}", starting_position.x-(@font.text_width("#{i}")/2), starting_position.y-(@font.height/2), 3)
            end
          end
        end
      end

      def draw_grid
        Gosu.clip_to(@active_area.x, @active_area.y, @active_area.width, @active_area.height) do
          ((@screen_vector.x % @tile_size) .. window.width).step(@tile_size) do |x|
            Gosu.draw_rect(x, @active_area.y, 1, @active_area.height, @grid_color)
          end

          ((@screen_vector.y % @tile_size) .. window.width).step(@tile_size) do |y|
            Gosu.draw_rect(@active_area.x, y, @active_area.width, 1, @grid_color)
          end
        end
      end

      def draw_messages
        _height = (Sidebar::PADDING*1.5)
        @editor_messages.each_with_index do |message, i|
          message.text.y = @selectors_height+_height
          _height+=message.text.height
          message.text.x = (Sidebar::PADDING*2)+@active_selector.instance.sidebar.widest_element
          if Time.now >= message.time_to_live
            message.alpha-=1
            message.text.alpha = message.alpha
            if message.alpha <= 0
              @editor_messages.shift
            end
          end
          message.text.draw
        end
      end

      def draw
        # Container selection buttons
        draw_mode_selectors

        @active_selector.instance.draw if @active_selector && @active_selector.instance

        draw_map

        draw_grid

        draw_messages
      end

      def update
        @active_area.x = @active_selector.instance.sidebar.widest_element if @active_selector && @active_selector.instance

        @active_selector.instance.update if @active_selector && @active_selector.instance

        update_map_offset

        update_ui_on_resize

        # @screen_vector.x = 0 if @screen_vector.x > 0
        # @screen_vector.y = 0 if @screen_vector.y > 0
      end

      def button_up(id)
        if id == Gosu::KbEscape
          if track_save_tainted?
            close_dialog { push_state(Track::Editor::Menu) }
            return
          else
            push_state(Track::Editor::Menu)
            return
          end
        end

        case id
        when Gosu::MsLeft
          width = $window.width.to_f/@mode_selectors.count
          @mode_selectors.each_with_index do |s, i|
            if mouse_over?(width*i, 0, width, @selectors_height)
              if s.instance
                @active_selector = s
                @active_selector.selected = true
                @active_selector.instance.focused
              end
            end
          end
        when Gosu::KbS
          if $window.button_down?(Gosu::KbLeftControl) || $window.button_down?(Gosu::KbRightControl)
            self.save_track
          end
        when Gosu::Kb0
          add_message "Reset screen position to 0:0"
          @screen_vector.x = 0
          @screen_vector.y = 0
        end

        @active_selector.instance.button_up(id) if @active_selector
      end

      def close_dialog(&block)
        dialog(:confirm, "Are you sure?", "Any unsaved changes will be lost!") { block.call }
      end

      def normalize_map_position(number)
        return (Integer((number / @tile_size).to_f.round(1).to_s.split('.').first)) * @tile_size
      end

      def update_map_offset(sensitivity = 3, speed = Gosu.fps/2)
        if $window.mouse_x.between?($window.width - sensitivity, $window.width)
          @screen_vector.x -= speed
        elsif $window.mouse_x.between?(0, 0+sensitivity)
          @screen_vector.x += speed
        end

        if $window.button_down?(Gosu::KbRight)
          @screen_vector.x -= speed
        end
        if $window.button_down?(Gosu::KbLeft)
          @screen_vector.x += speed
        end

        if $window.mouse_y.between?($window.height-sensitivity, $window.height)
          @screen_vector.y -= speed
        end
        if $window.mouse_y.between?(0, 0+sensitivity)
          @screen_vector.y += speed
        end

        if $window.button_down?(Gosu::KbUp)
          @screen_vector.y += speed
        end
        if $window.button_down?(Gosu::KbDown)
          @screen_vector.y -= speed
        end
      end

      def update_ui_on_resize
        if window.width != @window_width || window.height != @window_height

          resize_ui

          @window_width = window.width
          @window_height = window.height
        end
      end

      def resize_ui
        @tab_width = $window.width.to_f / @mode_selectors.count

        @mode_selectors.each do |s|
          s.text.text = s.name

          if s.text.width > @tab_width
            until(s.text.width <= @tab_width or s.text.width == s.text.textobject.text_width("..."))
              text = s.text.text.gsub(".", "")
              text = text[0...text.length-1]

              s.text.text = text + "..."
            end
          end
        end

        @active_area.width = window.width
        @active_area.height = window.height
      end

      def save_track
        push_state(
          Save, edit_state: self, tiles: @tiles, decorations: @decorations, checkpoints: @checkpoints,
          starting_positions: @starting_positions, background_color: @background, time_of_day: @time_of_day
        )
        @track_tainted = false if @save_file
      end

      def track_changed!
        @track_tainted = true
      end

      # Has the track been changed since last save?
      def track_save_tainted?
        @track_tainted
      end

      def dialog(type, title, caption, callback = nil, &block)
        _window = EditorWindow.new(type: type, title: title, caption: caption, callback: callback, block: block, editor: self)
        push_state(_window)
      end

      def add_message(string, time_to_live = 5)
        text    = CyberarmEngine::Text.new(string, y: -100, z: 255, size: 26, shadow: true, shadow_color: 0xff_000000, shadow_size: 1)
        message = EditorMessage.new(text, Time.now, Time.now + time_to_live, 255)
        @editor_messages << message
      end

      def mouse_in?(bounding_box)
        $window.mouse_x.between?(bounding_box.x, bounding_box.x + bounding_box.width) &&
          $window.mouse_y.between?(bounding_box.y, bounding_box.y + bounding_box.height)
      end

      def mouse_over?(x, y, width, height)
        $window.mouse_x.between?(x + 1, x - 1 + width) &&
          $window.mouse_y.between?(y, y - 1 + height)
      end
    end
  end
end