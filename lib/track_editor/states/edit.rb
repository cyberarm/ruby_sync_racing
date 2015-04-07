class Track::Editor::Edit < Chingu::GameState
  attr_accessor :save_file, :messages

  def setup
    @fps = Game::Text.new("", size: 20, x: $window.width-60, color: Gosu::Color::BLACK)
    @instructions = Game::Text.new("Instructions: Left click: Place track, Right click: Remove track, Scroll up/down: Change tile, 's': Save track, 'r': Reset track.",
                                    size: 22, color: Gosu::Color::BLACK)
    @tiles = []
    @tile_size = 64
    @mouse = Gosu::Image["assets/tracks/general/road/asphalt.png"]
    @mouse_pos = {x: 0, y: 0}
    @mouse_click = Gosu::Sample["assets/track_editor/click.ogg"]

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
  end

  def draw
    super
    # Draw background
    $window.fill(Gosu::Color.rgba(100, 255, 78, 144))
    $window.fill_rect([0, 0, $window.width, 20], Gosu::Color.rgba(255,255,255,140))

    # Draw grid
    ($window.width/64).times do |x|
        $window.draw_line(64*x, 0,Gosu::Color::WHITE, 64*x, $window.height, Gosu::Color::WHITE, 10)
      ($window.height/64).times do |y|
        $window.draw_line(0,64*y,Gosu::Color::WHITE, $window.width,64*y, Gosu::Color::WHITE, 10)
      end
    end

    @messages.each do |message|
      if message.is_a?(Hash)
        message[:text].draw
      end
    end

    @fps.draw
    @instructions.draw

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

    @mouse.draw(@mouse_pos[:x], @mouse_pos[:y], 15, 1, 1, Gosu::Color.rgba(255,255,255,150))
  end

  def update
    super
    @fps.text = "FPS:#{Gosu.fps}"
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
        @messages << "Map has content, can not close!"
        @messages << "Press Shift+Esc to force."
      end

    when Gosu::MsLeft
      _x = normalize($window.mouse_x)
      _y = normalize($window.mouse_y)

      @tiles[_x] = [_x] unless @tiles[_x]

      if @tiles[_x] && !@tiles[_x][_y].is_a?(Track::Tile)
        @mouse_click.play

        @tiles[_x][_y] = Track::Tile.new("asphalt",
                                         Gosu::Image[@mouse.name],
                                         _x,
                                         _y)
      end

    when Gosu::MsRight
      _x = normalize($window.mouse_x)
      _y = normalize($window.mouse_y)

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

    when Gosu::KbS
      push_game_state(Track::Editor::Save.new(tiles: @tiles))
    end
  end
end
