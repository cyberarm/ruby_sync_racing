class CarPhysics
  attr_reader :angle
  def initialize(entity)
    @entity = entity

    @angle = 0.0
    @key_active = false
  end

  def update
    calculate
  end

  def forward
    @key_active = true

    if @entity.speed >= 0.0
      @entity.braking = false
      @entity.speed += acceleration_force
    else
      @entity.braking = true
      @entity.speed += brake_force
    end
  end

  def reverse
    @key_active = true

    if @entity.speed <= 0.0
      @entity.braking = false
      @entity.speed -= acceleration_force
    else
      @entity.braking = true
      @entity.speed -= brake_force
    end
  end

  def turn_left
    @entity.angular_velocity -= turning_force
  end

  def turn_right
    @entity.angular_velocity += turning_force
  end

  def acceleration_force
    @entity.acceleration * dt
  end

  def turning_force
    @entity.turn_speed * dt
  end

  def brake_force
    @entity.brake_speed * dt
  end

  def drag_force
    @entity.drag * dt
  end

  def speed_force
    @entity.speed * dt
  end

  def dt
    Display.dt
  end

  def apply_drag
    if @entity.speed > 0.0
      @entity.speed -= drag_force
    elsif @entity.speed < 0.0
      @entity.speed += drag_force
    end
  end

  def calculate
    # Derived from: https://gamedev.stackexchange.com/a/1900

    apply_drag
    @entity.speed = @entity.speed.clamp(-@entity.top_speed, @entity.top_speed)

    @entity.velocity.x = speed_force * Math.cos(@entity.angle.gosu_to_radians)
    @entity.velocity.y = speed_force * Math.sin(@entity.angle.gosu_to_radians)

    @entity.position += @entity.velocity

    @entity.angle += @entity.angular_velocity
    @entity.angular_velocity *= @entity.angular_drag

    unless @key_active
      if @entity.speed.abs <= (@entity.brake_speed * Display.dt) then @entity.speed = 0.0; end
      @entity.braking = @entity.speed == 0
    end

    @key_active = false
  end
end
