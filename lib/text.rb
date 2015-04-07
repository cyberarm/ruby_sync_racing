class Game
  class Text
    attr_accessor :text, :x, :y, :z, :factor_x, :factor_y, :color, :options
    attr_reader :width, :height, :size, :font

    def initialize(text, options)
      @text = text
      @options = options

      @options[:x] ||= 0
      @options[:y] ||= 0
      @options[:z] ||= 11

      @options[:factor_x] ||= 1.0
      @options[:factor_y] ||= 1.0

      @options[:color] ||= Gosu::Color::WHITE
      @options[:size]  ||= 13

      @x = @options[:x]
      @y = @options[:y]
      @z = @options[:z]

      @factor_x = @options[:factor_x]
      @factor_y = @options[:factor_y]

      @color = @options[:color]
      @size  = @options[:size]

      @font = Gosu::Font.new($window, @options[:font], @options[:size])

      @width = @font.text_width(@text, @factor_x)
      @height = @font.height
    end

    def draw
      @font.draw(@text, @x, @y, @z, @factor_x, @factor_y, @color)
    end

    def update
      @width = @font.text_width(@text, @factor_x)
    end
  end
end
