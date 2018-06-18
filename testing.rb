require "gosu"
class Window < Gosu::Window
  def initialize
    super(720, 480, false)
    @font = Gosu::Font.new(24, name: Gosu.default_font_name)
  end

  def draw
    Gosu.draw_rect(0, 0, 64, 64, Gosu::Color.rgba(255,144,0, 150), 1000)
    @font.draw("NO", 10, 0, 1001)
    @font.draw("IMAGE", 2, 30, 1001)
  end
end

Window.new.show