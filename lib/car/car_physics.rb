class CarPhysics
  attr_reader :angle
  def initialize(entity)
    @entity = entity

    @angle = 0.0
  end

  def update
    calculate
  end

  def calculate
    # Derived from: https://gamedev.stackexchange.com/a/1900

    @entity.velocity_x = (@entity.speed * Display.dt) * Math.cos((90.0 + @entity.angle) * Math::PI / 180)
    @entity.velocity_y = (@entity.speed * Display.dt) * Math.sin((90.0 + @entity.angle) * Math::PI / 180)

    @entity.x -= @entity.velocity_x
    @entity.y -= @entity.velocity_y

    if @entity.speed > 0.0
      @entity.speed = @entity.top_speed if @entity.speed > @entity.top_speed
      @entity.speed -= @entity.drag * Display.dt
    elsif @entity.speed < 0.0
      @entity.speed = -@entity.top_speed if @entity.speed < -@entity.top_speed
      @entity.speed += @entity.drag * Display.dt
    end

    @entity.angle += @entity.angular_velocity
    @entity.angular_velocity *= @entity.angular_drag
  end
end
