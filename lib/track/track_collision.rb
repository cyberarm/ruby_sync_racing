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
        next unless tile.is_a?(Tile)

        @list[normalize(tile.x)] ||= {}
        @list[normalize(tile.x)][normalize(tile.y)] = tile
      end
    end

    def find(x, y)
      _x = normalize(x)
      _y = normalize(y)
      _tile = nil

      _tile = @list.dig(_x, _y)
      # p "#{_tile.type} -> #{_tile.x}:#{_tile.y}" if _tile && $debug

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
