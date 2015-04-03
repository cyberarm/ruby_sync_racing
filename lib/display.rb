class Display < Chingu::Window
  attr_accessor :show_cursor

  def initialize(width, height, fullscreen)
    super(width, height, fullscreen)

    @show_cursor = false
    $window = self
    $window.caption = "Ruby Sync Racing"

    push_game_state(Scene::Boot)
  end

  def needs_cursor?
    @show_cursor
  end
end
