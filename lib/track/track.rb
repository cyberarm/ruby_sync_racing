 # Contains all the tiles for track.
class Track < Chingu::GameObject
  Tile = Struct.new(:type, :image, :x, :y)

  def setup
    @track = Track::Parser.new(@options[:spec])

    @tiles = []
    process_tiles
  end

  def process_tiles
    @track.tiles.each do |tile|
      @tiles << Tile.new(tile["type"], Gosu::Image[tile["image"]], tile["x"], tile["y"])
    end

    p @tiles.count
  end

  def draw
    super
    @tiles.each do |tile|
      p @track.tiles.first
      p tile
      exit
      tile.image.draw(tile.x, tile.y, 3)
    end
  end
end
