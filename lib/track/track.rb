class Track < Chingu::GameObject
  # Contains all the tiles for track.

  def setup
    @track = Track::Parser.new(@options[:spec])
    p @track

    @tiles = []
    process_tiles
  end

  def process_tiles
    @track.tiles.each do |tile|
      @tiles << {tile: tile, image: Gosu::Image[tile["image"]]}
    end

    p @tiles
  end

  def draw
    super
    @tiles.each do |tile|
      tile[:image].draw(tile[:tile]["x"], tile[:tile]["y"], 3)
    end
  end
end
