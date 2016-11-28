 # Contains all the tiles for track.
class Track < Chingu::GameObject
  Tile = Struct.new(:type, :image, :x, :y, :z, :angle, :color)

  attr_reader :collision, :track, :tiles

  def setup
    @track = Track::Parser.new(@options[:spec])

    @tiles = []
    process_tiles

    @collision = Track::Collision.new(@tiles)
  end

  def process_tiles
    @track.tiles.each do |tile|
      @tiles << Tile.new(tile["type"], Gosu::Image[tile["image"]], tile["x"], tile["y"], nil)
    end
  end

  def draw
    super
    @tiles.each do |tile|
      if DEBUG && tile.color
        tile.image.draw(tile.x, tile.y, 3, 1, 1, tile.color)
      else
        tile.image.draw(tile.x, tile.y, 3, 1, 1)
      end
    end
  end
end
