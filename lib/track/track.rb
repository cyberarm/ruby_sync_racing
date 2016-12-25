 # Contains all the tiles for track.
class Track < Chingu::GameObject
  Tile = Struct.new(:type, :image, :x, :y, :z, :angle, :color)

  attr_reader :collision, :track, :tiles, :tile_size

  def setup
    @tile_size = 64
    @track = Track::Parser.new(@options[:spec])

    @tiles = []
    process_tiles

    @collision = Track::Collision.new(@tiles)
    @tile_size = @tiles.first.image.width
  end

  def process_tiles
    @track.tiles.each do |tile|
       _tile = Tile.new(tile["type"], Gosu::Image[tile["image"]], tile["x"], tile["y"], tile["z"], tile["angle"], nil)
       unless tile["z"] then _tile["z"] = 0; end
       unless tile["angle"] then _tile["angle"] = 0; end
      @tiles << _tile
    end
  end

  def draw
    super
    @tiles.each do |tile|
      if DEBUG && tile.color
        tile.image.draw_rot(tile.x+@tile_size/2, tile.y+@tile_size/2, tile.z, tile.angle, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)#tile.color)
      else
        tile.image.draw_rot(tile.x+@tile_size/2, tile.y+@tile_size/2, tile.z, tile.angle, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)
      end
    end
  end
end
