class GameState
  SCALE_X_BASE = 1920.0
  SCALE_Y_BASE = 1080.0
  attr_accessor :options, :global_pause
  attr_reader :game_objects

  def initialize(options={})
    $window.set_game_state(self)
    @options = options unless @options
    @game_objects = []
    @global_pause = false

    setup
    @_4ship = GameObject::Vertex.new
  end

  def setup
  end

  def draw
    # count = 0
    @game_objects.each do |o|
      o.draw if o.visible
      # p o.class if o.visible
      # count+=1 if o.visible
    end
    # puts "Num visible objects: #{count} of #{@game_objects.count}"
  end

  def update
    @game_objects.each do |o|
      unless o.paused || @global_pause
        o.world_center_point.x = @_4ship.x
        o.world_center_point.y = @_4ship.y

        o.update
        o.update_debug_text if $debug
      end
    end
  end

  def draw_bounding_box(box)
    x,y, max_x, max_y = box.x, box.y, box.max_x, box.max_y

    color = Gosu::Color.rgba(255, 127, 64, 240)

    # pipe = 4
    # Gosu.draw_rect(x-width, y-height, x+(width*2), y+(height*2), color, Float::INFINITY)
    # puts "BB render: #{x}:#{y} w:#{x.abs+width} h:#{y.abs+height}"
    # Gosu.draw_rect(x, y, x.abs+width, y.abs+height, color, Float::INFINITY)

    # TOP LEFT to BOTTOM LEFT
    $window.draw_line(
      x, y, color,
      x, max_y, color,
      Float::INFINITY
    )
    # BOTTOM LEFT to BOTTOM RIGHT
    $window.draw_line(
      x, max_y, color,
      max_x, max_y, color,
      Float::INFINITY
    )
    # BOTTOM RIGHT to TOP RIGHT
    $window.draw_line(
      max_x, max_y, color,
      max_x, y, color,
      Float::INFINITY
    )
    # TOP RIGHT to TOP LEFT
    $window.draw_line(
      max_x, y, color,
      x, y, color,
      Float::INFINITY
    )
  end

  def lighten(color, amount = 25)
    if defined?(color.alpha)
      return Gosu::Color.rgba(color.red+amount, color.green+amount, color.blue+amount, color.alpha)
    else
      return Gosu::Color.rgb(color.red+amount, color.green+amount, color.blue+amount)
    end
  end

  def darken(color, amount = 25)
    if defined?(color.alpha)
      return Gosu::Color.rgba(color.red-amount, color.green-amount, color.blue-amount, color.alpha)
    else
      return Gosu::Color.rgb(color.red-amount, color.green-amount, color.blue-amount)
    end
  end

  def image(image_path)
    image = nil
    GameObject::IMAGES.detect do |img, instance|
      if img == image_path
        image = instance
        true
      end
    end

    unless image
      instance = Gosu::Image.new(image_path)
      GameObject::IMAGES[image_path] = instance
      image = instance
    end

    return image
  end

  def sample(sample_path)
    sample = nil
    GameObject::SAMPLES.detect do |smp, instance|
      if smp == sample_path
        sample = instance
        true
      end
    end

    unless sample
      instance = Gosu::Sample.new(sample_path)
      GameObject::SAMPLES[sample_path] = instance
      sample = instance
    end

    return sample
  end

  def song()
  end

  def destroy
    @options = nil
    @game_objects = nil
  end

  def button_up(id)
    @game_objects.each do |o|
      o.button_up(id) unless o.paused
    end
  end

  def push_game_state(klass, options={})
    $window.push_game_state(klass, options)
  end

  def fill_rect(x, y, width, height, color, z = 0)
    $window.draw_rect(x,y,width,height,color,z)
  end

  def fill(color = Gosu::Color::WHITE, z = 0)
    fill_rect(0 ,0, $window.width, $window.height, color, z)
  end

  def add_game_object(object)
    @game_objects << object
  end
end
