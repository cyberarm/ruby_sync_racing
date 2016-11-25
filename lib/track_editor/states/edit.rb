class Track::Editor::Edit < Chingu::GameState
  attr_accessor :save_file, :messages

  def setup
    @screen_vector = Vector2D.new(0, 0)
    @fps = Game::Text.new("", size: 20, x: $window.width-60, color: Gosu::Color::BLACK)
    @information = Game::Text.new("", size: 18, color: Gosu::Color::BLACK)
    @tile_size = 64
    @tiles = []
    @decorations = []
    @checkpoints = []
    @mouse = Gosu::Image["assets/tracks/general/road/asphalt.png"]
    @mouse_pos = {x: 0, y: 0}
    @mouse_click = Gosu::Sample["assets/track_editor/click.ogg"]
    @error_sound = Gosu::Sample["assets/track_editor/error.ogg"]

    @tile_index  = 0
    @track_tiles = ["assets/tracks/general/road/asphalt.png",
                    "assets/tracks/general/road/asphalt_top.png",
                    "assets/tracks/general/road/asphalt_bottom.png",
                    "assets/tracks/general/road/asphalt_right.png",
                    "assets/tracks/general/road/asphalt_left.png",
                    "assets/tracks/general/road/asphalt_left_top.png",
                    "assets/tracks/general/road/asphalt_left_bottom.png",
                    "assets/tracks/general/road/asphalt_right_top.png",
                    "assets/tracks/general/road/asphalt_right_bottom.png"]

    @messages = []
    @save_file = nil

    if @options[:track_file]
      @track_file = @options[:track_file]
      @save_file = File.basename(@track_file)
      p self.save_file
      @track_data = AbstractJSON.load(File.open(@track_file).read)

      @track_data["tiles"].each do |tile|
        _x = tile["x"]
        _y = tile["y"]

        @tiles[_x] = [_x] unless @tiles[_x]

        if @tiles[_x] && !@tiles[_x][_y].is_a?(Track::Tile)
          _tile = Track::Tile.new(tile["type"],
                                  Gosu::Image[tile["image"]],
                                  _x,
                                  _y)
          @tiles[_x][_y] = _tile
        end
      end
    end
  end

  def draw
    super
    # Draw background
    $window.fill(Gosu::Color.rgba(100, 255, 78, 144))
    $window.fill_rect([0, 0, $window.width, 20], Gosu::Color.rgba(255,255,255,140))

    # Draw grid
    ($window.width/@tile_size).times do |x|
        $window.draw_line(@tile_size*x, 0,Gosu::Color::WHITE, @tile_size*x, $window.height, Gosu::Color::WHITE, 10)
      ($window.height/@tile_size).times do |y|
        $window.draw_line(0,@tile_size*y,Gosu::Color::WHITE, $window.width,@tile_size*y, Gosu::Color::WHITE, 10)
      end
    end

    @messages.each do |message|
      if message.is_a?(Hash)
        message[:text].draw
      end
    end

    @fps.draw
    @information.draw

    #Window Translation
    $window.translate(@screen_vector.x, @screen_vector.y) do
      @tiles.each do |x|
        if x
          x.each do |y|
            if y.is_a?(Track::Tile)
              tile = y
              tile.image.draw(tile.x, tile.y, 5)
            end
          end
        end
      end
    end

    @mouse.draw(@mouse_pos[:x], @mouse_pos[:y], 15, 1, 1, Gosu::Color.rgba(255,255,255,150))
  end

  def update
    super
    _tile_count = 0
    @tiles.each {|x| if x then x.each {|y| if y.is_a?(Track::Tile); _tile_count+=1;end};end}

    @fps.text = "FPS:#{Gosu.fps}"
    @information.text = "Tiles: #{_tile_count}, Decorations: #{@decorations.count}, Checkpoints: #{@checkpoints.count}|Screen Vector2D: #{@screen_vector.x}-#{@screen_vector.y}"

    @mouse_pos[:x] = $window.mouse_x-@mouse.width/2
    @mouse_pos[:y] = $window.mouse_y-@mouse.height/2

    _y = 30
    @messages.each_with_index do |message, index|
      if message.is_a?(String)
        text = Game::Text.new("#{message}", x: 30, size: 26, z: 100, color: Gosu::Color::WHITE)
        _message = {text: text, time: (message.length/10)*60, alpha: 255}
        @messages[index] = _message
      end

      if message.is_a?(Hash)
        message[:time]-=1
        message[:alpha]-=2 if message[:time] <= 0
        message[:text].color = Gosu::Color.rgba(255,255,255,message[:alpha])

        message[:text].y = _y
        if message[:alpha] <= 0
          @messages.delete_at(index)
        end
      end
      _y+=30
    end

    if ($window.button_down?(Gosu::KbLeftShift) || $window.button_down?(Gosu::KbRightShift)) && $window.button_down?(Gosu::KbEscape)
      @messages << "FORCE CLOSE!"
      push_game_state(Track::Editor::Menu)
    end

    button_down_input_checker
  end

  def normalize(integer)
    string = (integer/@tile_size).to_f.round(1).to_s
    array  = string.split('.')
    number = array[0].to_i

    number = (number*@tile_size)
    return number
  end

  def button_up(id)
    case id
    when Gosu::KbEscape
      if @tiles.count == 0
        push_game_state(Track::Editor::Menu)
      else
        @messages << "Map has content, can not close! Press 'Shift'+'Escape' to force."
      end

    when Gosu::MsLeft
      _x = normalize($window.mouse_x-@screen_vector.x)
      _y = normalize($window.mouse_y-@screen_vector.y)

      @tiles[_x] = [_x] unless @tiles[_x]

      if @tiles[_x] && !@tiles[_x][_y].is_a?(Track::Tile)
        @mouse_click.play

        @tiles[_x][_y] = Track::Tile.new("asphalt",
                                         Gosu::Image[@mouse.name],
                                         _x,
                                         _y)
      else
        @error_sound.play
      end

    when Gosu::MsRight
      _x = normalize($window.mouse_x-@screen_vector.x)
      _y = normalize($window.mouse_y-@screen_vector.y)

      if @tiles[_x].is_a?(Array)
        if @tiles[_x][_y].is_a?(Track::Tile)
          @mouse_click.play
          @tiles[_x][_y] = nil
        end
      end

    when Gosu::MsWheelUp
      @tile_index+=1
      @tile_index = @track_tiles.index(@track_tiles.first) if @tile_index > @track_tiles.count-1
      @mouse = Gosu::Image[@track_tiles[@tile_index]]

    when Gosu::MsWheelDown
      @tile_index-=1

      @tile_index = @track_tiles.index(@track_tiles.last) if @tile_index < 0
      @mouse = Gosu::Image[@track_tiles[@tile_index]]

    when Gosu::MsMiddle
      _x = normalize($window.mouse_x)
      _y = normalize($window.mouse_y)

      if @tiles[_x]
        if @tiles[_x][_y]
          @mouse = @tiles[_x][_y].image
        end
      end

    # Screen offect
  when Gosu::KbW, Gosu::KbUp
      @screen_vector.y+=@tile_size

    when Gosu::KbS, Gosu::KbDown
      @screen_vector.y-=@tile_size

    when Gosu::KbA, Gosu::KbLeft
      @screen_vector.x+=@tile_size

    when Gosu::KbD, Gosu::KbRight
      @screen_vector.x-=@tile_size

    when Gosu::Kb0
      @messages << "Screen reset to default position"
      @screen_vector.x=0
      @screen_vector.y=0
    end
  end

  def button_down_input_checker
    if ($window.button_down?(Gosu::KbLeftControl) or $window.button_down?(Gosu::KbRightControl)) && $window.button_down?(Gosu::KbS)
      push_game_state(Track::Editor::Save.new(tiles: @tiles, decorations: @decorations, checkpoints: @checkpoints))
    end
  end
end
