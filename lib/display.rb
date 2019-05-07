class Display < CyberarmEngine::Engine
  def initialize(width = 800, height = 600, fullscreen = false, update_interval = 1000.0/60)
    if Config.get(:screen_width).downcase == "max" then dwidth = Gosu.screen_width; else dwidth = Integer(Config.get(:screen_width)); end
    if Config.get(:screen_height).downcase == "max" then dheight = Gosu.screen_height; else dheight = Integer(Config.get(:screen_height)); end
    if Integer(Config.get(:screen_fullscreen)) == 1 then dfullscreen = true; else dfullscreen = false; end
    p dwidth, dheight, dfullscreen, Config.instance if $debug
    if ARGV.join.include?("--slow")
      super(width: dwidth, height: dheight, fullscreen: dfullscreen, update_interval: 1000.0/20, resizable: true)
    else
      super(width: dwidth, height: dheight, fullscreen: dfullscreen, update_interval: update_interval, resizable: true)
    end

    @show_cursor = false
    $window = self
    @last_frame_time = Gosu.milliseconds-1
    @current_frame_time = Gosu.milliseconds
    $window.caption = "Ruby Sync Racing"

    if ARGV.join.include?("--quick")
      push_state(Game::Scene::MainMenu)
    else
      push_state(Game::Scene::Boot)
    end
  end

  def button_up(id)
    $debug = !$debug if ARGV.join.include?("--debug") && id == Gosu::KbBacktick
    super
  end
end
