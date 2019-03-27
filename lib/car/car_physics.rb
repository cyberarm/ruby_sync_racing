class CarPhysics
  attr_reader :angle
  def initialize(entity)
    @entity = entity

    @angle = 0.0
  end

  def update
    calculate
  end

  def forward
    if @entity.speed >= 0.0
      @entity.braking = false
      @entity.speed += acceleration_force
    else
      @entity.braking = true
      puts "braking"
      @entity.speed += brake_force
    end
  end

  def reverse
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

    @entity.velocity_x = speed_force * Math.cos(@entity.angle.gosu_to_radians)
    @entity.velocity_y = speed_force * Math.sin(@entity.angle.gosu_to_radians)

    @entity.x += @entity.velocity_x
    @entity.y += @entity.velocity_y

    @entity.angle += @entity.angular_velocity
    @entity.angular_velocity *= @entity.angular_drag
  end
end
