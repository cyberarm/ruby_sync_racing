class Track::Editor::Edit < GameState
  attr_accessor :save_file, :messages

  def setup
    @screen_vector = Vector2D.new(0, 0)
    @fps = Game::Text.new("", size: 20, x: $window.width-60, color: Gosu::Color::BLACK)
    @information = Game::Text.new("", size: 18, color: Gosu::Color::BLACK)
    @tile_size = 64
    @tiles = []
    @decorations = []
    @checkpoints = []
    @mouse = image("assets/tracks/general/road/asphalt.png")
    @mouse_pos = {x: 0, y: 0, angle: 0}
    @mouse_click = sample("assets/track_editor/click.ogg")
    @error_sound = sample("assets/track_editor/error.ogg")

    @tile_index  = 0
    @tile_type   = "asphalt"
    @track_tiles = ["assets/tracks/general/road/asphalt.png",
                    "assets/tracks/general/road/asphalt_left.png",
                    "assets/tracks/general/road/asphalt_left_bottom.png"]

    @messages = []
    @edit_modes = [:track, :decoration, :checkpoint, :spawn]
    @edit_mode  = 0
    @save_file = nil

    if @options[:track_file]
      @track_file = @options[:track_file]
      @save_file = File.basename(@track_file)
      p self.save_file
      @track_data = AbstractJSON.load(File.open(@track_file).read)

      @track_data["tiles"].each do |tile|
        _x = tile["x"]
        _y = tile["y"]
        _z = tile["z"]
        _angle = tile["angle"]
        # Correct for old maps that don't have z and angle stored.
        _z     ||= 0
        _angle ||= 0

        @tiles[_x] = [_x] unless @tiles[_x]

        if @tiles[_x] && !@tiles[_x][_y].is_a?(Track::Tile)
          _tile = Track::Tile.new(tile["type"],
                                  image(tile["image"]),
                                  _x,
                                  _y,
                                  _z,
                                  _angle)
          @tiles[_x][_y] = _tile
          p _tile
        end
      end
    end
  end

  def draw
    super
    # Draw background
    fill(Gosu::Color.rgba(100, 255, 78, 144))
    $window.fill_rect(0, 0, $window.width, 20, Gosu::Color.rgba(255,255,255,140))

    # Draw grid
    ($window.width/@tile_size+1).times do |x|
        $window.draw_line(@tile_size*x, 0,Gosu::Color::WHITE, @tile_size*x, $window.height, Gosu::Color::WHITE, 10)
      ($window.height/@tile_size+1).times do |y|
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
              tile.image.draw_rot(tile.x+@tile_size/2, tile.y+@tile_size/2, 5, tile.angle, 0.5, 0.5, 1, 1)
            end
          end
        end
      end
    end

    @mouse.draw_rot($window.mouse_x, $window.mouse_y, 15, @mouse_pos[:angle], 0.5, 0.5, 1, 1, Gosu::Color.rgba(255,255,255,150))
  end

  def update
    super
    @fps.text = "FPS:#{Gosu.fps}"
    @information.text = "Tiles: #{tile_count}, Decorations: #{@decorations.count}, Checkpoints: #{@checkpoints.count}|Screen Vector2D: #{@screen_vector.x}-#{@screen_vector.y} | Mouse Pos: #{@mouse_pos[:x]}-#{@mouse_pos[:x]}_#{@mouse_pos[:angle]} | AX: #{normalize($window.mouse_x-@screen_vector.x)} AY: #{normalize($window.mouse_y-@screen_vector.y)}"

    @mouse_pos[:x] = ($window.mouse_x-@screen_vector.x)-@mouse.width/2
    @mouse_pos[:y] = ($window.mouse_y-@screen_vector.y)-@mouse.height/2

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

  def tile_count(tiles_array = @tiles)
    _tile_count = 0
    tiles_array.each {|x| if x then x.each {|y| if y.is_a?(Track::Tile); _tile_count+=1;end};end}
    return _tile_count
  end

  def normalize(integer)
    string = (integer/@tile_size).to_f.round(1).to_s
    array  = string.split('.')
    number = array[0].to_i

    return number
  end

  def button_up(id)
    case id
    when Gosu::KbEscape
      if tile_count == 0
        push_game_state(Track::Editor::Menu)
      else
        @messages << "Map has content, can not close! Press 'Shift'+'Escape' to force."
      end

    when Gosu::KbTab
      if @edit_mode < @edit_modes.count-1
        @edit_mode+=1
      else
        @edit_mode = 0
      end

      @messages << "Mode switched [#{@edit_modes[@edit_mode]}]"

    when Gosu::MsLeft
      _x = normalize($window.mouse_x-@screen_vector.x)
      _y = normalize($window.mouse_y-@screen_vector.y)
      _z = 0
      _angle = @mouse_pos[:angle]

      @tiles[_x] = [_x] unless @tiles[_x]

      if @tiles[_x] && !@tiles[_x][_y].is_a?(Track::Tile)
        @mouse_click.play

        @tiles[_x][_y] = Track::Tile.new(@tile_type,
                                         image(@mouse.name),
                                         _x*@tile_size,
                                         _y*@tile_size,
                                         _z,
                                         _angle)
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

    when Gosu::MsWheelUp, Gosu::KbJ
      @tile_index+=1
      @tile_index = @track_tiles.index(@track_tiles.first) if @tile_index > @track_tiles.count-1
      @mouse = image(@track_tiles[@tile_index])

    when Gosu::MsWheelDown, Gosu::KbK
      @tile_index-=1

      @tile_index = @track_tiles.index(@track_tiles.last) if @tile_index < 0
      @mouse = image(@track_tiles[@tile_index])

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
      @screen_vector.y+=@tile_size unless @screen_vector.y-@tile_size >= 0

    when Gosu::KbS, Gosu::KbDown
      @screen_vector.y-=@tile_size

    when Gosu::KbA, Gosu::KbLeft
      @screen_vector.x+=@tile_size unless @screen_vector.x-@tile_size >= 0

    when Gosu::KbD, Gosu::KbRight
      @screen_vector.x-=@tile_size

    when Gosu::Kb0
      @messages << "Screen reset to default position"
      @screen_vector.x=0
      @screen_vector.y=0

    when Gosu::KbR
       @mouse_pos[:angle]+=90
       @mouse_pos[:angle]%=360
    end
  end

  def button_down_input_checker
    if ($window.button_down?(Gosu::KbLeftControl) or $window.button_down?(Gosu::KbRightControl)) && $window.button_down?(Gosu::KbS)
      push_game_state(Track::Editor::Save.new(tiles: @tiles, decorations: @decorations, checkpoints: @checkpoints))
    end
  end
end
