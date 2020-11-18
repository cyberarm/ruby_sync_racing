module Game
  class Viewport
    include CyberarmEngine::Common

    attr_reader :x, :y, :width, :height
    def initialize(position:)
      @position = position

      @x, @y  = 0, 0
      @width, @height = 0, 0
      @lag_x, @lag_y = 0.0, 0.0

      @screen_vector = CyberarmEngine::Vector.new(0.0, 0.0)
      @scale = 1.0
    end

    def lag=(lag)
      @lag_x, @lag_y = lag, lag
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        Gosu.scale(@scale, @scale, @x + @width / 2, @y + @height / 2) do
          Gosu.translate(-@screen_vector.x.to_i, -@screen_vector.y.to_i) do
            render_transformed
          end
        end

        render

        draw_border
      end
    end

    def render
    end

    def render_transformed
    end

    def update
      position_viewport
    end

    def center_around(entity)
      @screen_vector.x = ((entity.position.x - @x) - @width  / 2)
      @screen_vector.y = ((entity.position.y - @y) - @height / 2)
    end

    def move_towards(entity)
      @screen_vector.x += (((entity.position.x - @x) - @width  / 2) - @screen_vector.x) * (1.0 - @lag_x)# * $window.dt
      @screen_vector.y += (((entity.position.y - @y) - @height / 2) - @screen_vector.y) * (1.0 - @lag_y)# * $window.dt
    end

    def move_ahead_of(entity, ahead_by)
      heading = (entity.position - entity.last_position).normalized * ahead_by

      center_around(entity)

      @screen_vector += heading
    end

    def position_viewport
      case @position
      when :top
        @x, @y = 0, 0
        @width, @height = $window.width, $window.height / 2
      when :bottom
        @x, @y = 0, $window.height / 2
        @width, @height = $window.width, $window.height / 2

      when :top_left
        @x, @y = 0, 0
        @width, @height = $window.width / 2, $window.height / 2
      when :top_right
        @x, @y = $window.width / 2, 0
        @width, @height = $window.width / 2, $window.height / 2

      when :bottom_left
        @x, @y = 0, $window.height / 2
        @width, @height = $window.width / 2, $window.height / 2
      when :bottom_right
        @x, @y = $window.width / 2, $window.height / 2
        @width, @height = $window.width / 2, $window.height / 2

      else
        @x, @y = 0, 0
        @width, @height = $window.width, $window.height
      end
    end

    def draw_bounding_box(box)
      $window.current_state.draw_bounding_box(box)
    end

    def draw_border
      Gosu.draw_line(@x + @width, @y, @border_color, @x + @width, @y + @height, @border_color, Float::INFINITY)  # Right
      Gosu.draw_line(@x + @width, @y + @height, @border_color, @x, @y + @height, @border_color, Float::INFINITY) # Bottom
      Gosu.draw_line(@x + 1, @y + @height, @border_color, @x + 1, @y, @border_color, Float::INFINITY) # Left
      Gosu.draw_line(@x, @y + 1, @border_color, @x + @width, @y + 1, @border_color, Float::INFINITY)  # Top
    end
  end
end