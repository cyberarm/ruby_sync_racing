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

    @entity.x += @entity.velocity_x
    @entity.y += @entity.velocity_y

    @entity.velocity_x *= @entity.drag
    @entity.velocity_y *= @entity.drag

    @entity.angle += @entity.angular_velocity
    @entity.angular_velocity *= @entity.angular_drag
  end
end
