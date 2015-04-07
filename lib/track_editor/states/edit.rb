class Track::Editor::Edit < Chingu::GameState
  def setup
    @fps = Game::Text.new("", size: 20, x: $window.width-60, color: Gosu::Color::BLACK)
    @instructions = Game::Text.new("Instructions: Left click: Place track, Right click: Remove track, Scroll up/down: Change tile, 's': Save track, 'r': Reset track.",
                                    size: 22, color: Gosu::Color::BLACK)
    @tiles = []
    @tile_size = 64
    @mouse = Gosu::Image["assets/tracks/general/road/asphalt.png"]
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

    @fps.draw
    @instructions.draw

    @tiles.each do |x|
      if x
        x.each do |y|
          if y.is_a?(Tile)
            tile = y
            tile.image.draw(tile.x, tile.y, 5)
          end
        end
      end
    end

    @mouse.draw($window.mouse_x-@mouse.width/2, $window.mouse_y-@mouse.height/2, 15, 1, 1, Gosu::Color.rgba(255,255,255,150))
  end

  def update
    super
    @fps.text = "FPS:#{Gosu.fps}"
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
    when Gosu::MsLeft
      _x = normalize($window.mouse_x)
      _y = normalize($window.mouse_y)

      @tiles[_x] = [_x] unless @tiles[_x]

      if @tiles[_x] && !@tiles[_x][_y].is_a?(Tile)
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
        if @tiles[_x][_y].is_a?(Tile)
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
      push_game_state(Chingu::GameStates::Popup.new(text: "Planet Earth"))
      # puts
      # print "Enter Tracks Name => "
      # name = $stdin.gets.chomp
      # puts
      # puts "========================="
      # puts "Saving... track_#{name.downcase}.json"
      # hash = {"name" => "#{name}",
      #         "background"  => {"red"=> 100,
      #                        "green" => 254,
      #                        "blue"  =>  78,
      #                        "alpha" => 144},
      #         "tiles" => [], "decorations" => [], "checkpoints" => []}
      #
      # @tiles.each do |x|
      #   if x
      #     x.each do |tile|
      #       if tile.is_a?(Tile)
      #         hash["tiles"] << {"type" => "asphalt",
      #                           "image"=> tile.image.name,
      #                           "x" => tile.x,
      #                           "y" => tile.y}
      #       end
      #     end
      #   end
      # end
      #
      # data = MultiJson.dump(hash)
      # unless File.exist?("data/tracks/custom/#{name.downcase}.json")
      #   File.open("data/tracks/custom/#{name.downcase}.json", "w").write(data)
      # end
      # puts "SAVED."
      # puts "========================="
    end
  end
end
