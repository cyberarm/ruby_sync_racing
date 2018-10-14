class Track
  class Collision
    attr_reader :list

    def initialize(tile_list, tile_size = 64)
      @tiles = tile_list
      @tile_size = tile_size
      @list = {}

      process_tiles
    end

    def process_tiles
      @tiles.each do |tile|
        @list[tile.x] = []
        @list[tile.x] << tile
      end
    end

    def find(x, y)
      _x = normalize(x)
      _y = normalize(y)
      _tile = nil

      if @list[_x].is_a?(Array)
        @list[_x].detect do |tile|
          if tile.y == _y
            _tile = tile
            true
          end
        end
      end

      return _tile
    end

    def normalize(integer)
      string = (integer/@tile_size).to_f.round(1).to_s
      array  = string.split('.')
      number = array[0].to_i

      number = (number*@tile_size)
      return number
    end
  end
end
