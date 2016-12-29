module Game
  class Display < Chingu::Window
    attr_accessor :show_cursor

    def initialize(width = 0, height = 0, fullscreen = true)
      if Config.get(:screen_width).downcase == "max" then dwidth = Gosu.screen_width; else dwidth = Integer(Config.get(:screen_width)); end
      if Config.get(:screen_height).downcase == "max" then dheight = Gosu.screen_height; else dheight = Integer(Config.get(:screen_height)); end
      if Integer(Config.get(:screen_fullscreen)) == 1 then dfullscreen = true; else dfullscreen = false; end
      p dwidth, dheight, dfullscreen, Config.instance
      super(dwidth, dheight, dfullscreen)

      @show_cursor = false
      $window.caption = "Ruby Sync Racing"

      push_game_state(Scene::Boot)
    end

    def needs_cursor?
      @show_cursor
    end
  end
end
