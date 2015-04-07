class Track
  class Editor < Chingu::Window
    def initialize
      super(1280,832,false)
      @fps = Game::Text.new("", size: 20, x: $window.width-60)
      @instructions = Game::Text.new("Left click: Place track, Right click: Remove track, Scroll up/down: Change tile, 's': Save track, 'r': Reset track.", size: 25, color: Gosu::Color::BLUE)
      self.caption = "Track Editor - Ruby Sync Racing"

      @tiles = []
      @tile_size = 64
      @mouse = Gosu::Image["assets/tracks/general/road/asphalt.png"]

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

    def needs_cursor?
      true
    end

    def draw
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
            @tiles[_x][_y] = nil
          end
        end

      when Gosu::MsWheelUp
        p "Up"
        @tile_index+=1
        @tile_index = @track_tiles.index(@track_tiles.first) if @tile_index > @track_tiles.count-1
        @mouse = Gosu::Image[@track_tiles[@tile_index]]

      when Gosu::MsWheelDown
        p "DOwn"
        @tile_index-=1

        @tile_index = @track_tiles.index(@track_tiles.last) if @tile_index < 0
        @mouse = Gosu::Image[@track_tiles[@tile_index]]

      when Gosu::KbS
        puts
        print "Save Map as:"
        name = $stdin.gets.chomp
        puts
        puts "========================="
        puts "Saving... track_#{name.downcase}.json"
        hash = {}
        puts "========================="
      end
    end
  end
end
