 # Contains all the tiles for track.
class Track < GameObject
  Tile = Struct.new(:type, :image, :x, :y, :z, :angle, :color)
  Decoration = Struct.new(:collidable, :image, :x, :y, :z, :angle, :scale, :radius)
  StartingPosition = Struct.new(:x, :y, :angle)
  CheckPoint = Struct.new(:x, :y, :width, :height)

  Box = Struct.new(:x, :y, :max_x, :max_y)

  attr_reader :collision, :track, :tiles, :decorations, :checkpoints, :starting_positions, :tile_size
  attr_reader :x, :y, :width, :height, :scale, :bounding_box

  def setup
    @x,@y,@width,@height, @scale = 0,0,1,1, 1.0
    @bounding_box = Box.new(10_000,10_000, -10_000,-10_000)

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
    @tile_size = @tiles.first.image.width if @tiles.first

    calculate_boundry
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

  def calculate_boundry
    @tiles.each do |tile|
      @x = (tile.x) if (tile.x) < @x
      @y = (tile.y) if (tile.y) < @y

      @width = @x+(tile.x) if @x+(tile.x) > @width
      @height= @y+(tile.y) if @y+(tile.y) > @height

      @bounding_box.x = (tile.x) if (tile.x) < @bounding_box.x
      @bounding_box.y = (tile.y) if (tile.y) < @bounding_box.y

      @bounding_box.max_x = (tile.x+@tile_size) if (tile.x+@tile_size) > @bounding_box.max_x
      @bounding_box.max_y = (tile.y+@tile_size) if (tile.y+@tile_size) > @bounding_box.max_y
    end
  end

  def draw
    super

    begin
      draw_with_render # Render to an Image. Is a single image, when scaling there are no apparent artifacts.
    rescue RuntimeError # Rescue from "Incomplete Framebuffer." Maybe rescues when framebuffer is not supported?
      draw_with_record # Render with VAO, draw all at once. When scaling in and out floating point errors will be noticable as odd spaces between tiles.
    end
  end

  # Renders map
  def render
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
  end

  def draw_with_render
    @_img ||= Gosu.render(@bounding_box.x.abs + @bounding_box.max_x.abs, @bounding_box.y.abs + @bounding_box.max_y.abs) do
      Gosu.translate(@x.abs, @y.abs) do
        render
      end
    end

    @_img.draw(@x, @y, @tiles.first.z) if @tiles.first
  end

  def draw_with_record
    @_img ||= Gosu.record(@bounding_box.x.abs + @bounding_box.max_x.abs, @bounding_box.y.abs + @bounding_box.max_y.abs) do
      Gosu.translate(@x.abs, @y.abs) do
        render
      end
    end

    @_img.draw(@x, @y, @tiles.first.z) if @tiles.first
  end
end
