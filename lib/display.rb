class Game
  class Display < Chingu::Window
    attr_accessor :show_cursor

    def initialize(width = 1280, height = 832, fullscreen = false)
      super(width, height, fullscreen)

      @show_cursor = false
      $window.caption = "Ruby Sync Racing"

      push_game_state(Scene::Boot)
    end

    def needs_cursor?
      @show_cursor
    end
  end
end
