 # Contains all the tiles for track.
class Track < GameObject
  Tile = Struct.new(:type, :image, :x, :y, :z, :angle, :color)
  Decoration = Struct.new(:collidable, :image, :x, :y, :z, :angle, :scale, :radius)
  StartingPosition = Struct.new(:x, :y, :angle)
  CheckPoint = Struct.new(:x, :y, :width, :height)

  attr_reader :collision, :track, :tiles, :decorations, :checkpoints, :starting_positions, :tile_size

  def setup
    @tile_size = 64
    @track = Track::Parser.new(@options[:spec])

    @tiles = []
    process_tiles

    @decorations = []
    begin
      process_decorations
    rescue NoMemoryError
    end

    @checkpoints = []
    begin
      process_checkpoints
    rescue NoMethodError
    end

    @starting_positions = []
    begin
      process_starting_positions
    rescue NoMethodError
    end

    @collision = Track::Collision.new(@tiles)
    @tile_size = @tiles.first.image.width
  end

  def process_tiles
    @track.tiles.each do |tile|
       _tile = Tile.new(tile["type"], image(AssetManager.image_from_id(tile["image"])), tile["x"], tile["y"], tile["z"], tile["angle"], nil)
       unless tile["z"] then _tile["z"] = 0; end
       unless tile["angle"] then _tile["angle"] = 0; end
      @tiles << _tile
    end
  end

  def process_decorations
    @track.decorations.each do |decoration|
      @decorations << Decoration.new(decoration["collidable"], image(AssetManager.image_from_id(decoration["image"])), decoration["x"], decoration["y"], decoration["z"], decoration["angle"], decoration["scale"], nil)
    end
  end

  def process_checkpoints
    @track.checkpoints.each do |checkpoint|
      # Correct for some weirdness by adding half a tile to the X/Y position
      @checkpoints << CheckPoint.new(checkpoint["x"]+@tile_size/2, checkpoint["y"]+@tile_size/2, checkpoint["width"], checkpoint["height"])
    end
  end

  def process_starting_positions
    @track.starting_positions.each do |starting_position|
      @starting_positions << StartingPosition.new(starting_position["x"], starting_position["y"], starting_position["angle"])
    end
  end

  def draw
    super
    @tiles.each do |tile|
      if $debug && tile.color
        tile.image.draw_rot(tile.x+@tile_size/2, tile.y+@tile_size/2, tile.z, tile.angle, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)#tile.color)
      else
        tile.image.draw_rot(tile.x+@tile_size/2, tile.y+@tile_size/2, tile.z, tile.angle, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)
      end
    end

    @decorations.each do |decoration|
      decoration.image.draw_rot(decoration.x, decoration.y, decoration.z, decoration.angle, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)
    end

    if $debug
      @checkpoints.each do |checkpoint|
        Gosu.draw_rect(checkpoint.x, checkpoint.y, checkpoint.width, checkpoint.height, Gosu::Color.rgba(200,200,200, 200), 5)
      end
    end
  end
end
