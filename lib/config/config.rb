class Config
  attr_writer :config_loaded
  attr_reader :known_settings

  def self.inherited
  end

  def self.ensure_config_exists
    if File.exists?("./data/config.ini") && File.file?("./data/config.ini")
    else
      string = <<-EOF
      #NOTE: Changes here won't take effect until the game is relaunched
      screen_width max
      screen_height max
      screen_fullscreen 1
      player_username SyncRacer
      player_last_host localhost
      player_last_port 56789

      player_1_forward    w
      player_1_reverse    s
      player_1_turn_left  a
      player_1_turn_right d
      player_1_headlights l

      player_2_forward    Up
      player_2_reverse    Down
      player_2_turn_left  Left
      player_2_turn_right Right
      player_2_headlights /
      EOF
      File.open("./data/config.ini", "w") {|f| f.write string}
    end
  end

  def initialize(config_file)
    Config.instance = self
    @config_loaded  = false
    @known_settings = {}
    @settings = [
      :screen_width, :screen_height, :screen_fullscreen,
      :player_username, :player_last_host, :player_last_port,
      :player_1_forward, :player_1_reverse, :player_1_turn_left, :player_1_turn_right, :player_1_headlights,
      :player_2_forward, :player_2_reverse, :player_2_turn_left, :player_2_turn_right, :player_2_headlights
    ]
    @parser = Parser.new(config_file, self)
  end

  def set(key, value)
    if @settings.detect {|s| s == key.to_sym} then @known_settings[key.to_sym] = value; end
  end

  def self.set(key, value)
    Config.instance.set(key, value)
  end

  def get(key)
    @known_settings[key]
  end

  # Writes config data from @known_settings hash to config.ini. OVERWRITES!
  def write(config_file = "./data/config.ini")
    if @config_loaded
      File.open(config_file, "w") do |f|
        @known_settings.each do |key, value|
          f.write("#{key} #{value}\n")
        end
      end
    end
  end

  def self.save
    if Config.instance
      Config.instance.write("./data/config.ini")
    else
      raise "No Instance of Config"
    end
  end

  def self.get(key)
    Config.instance.get(key)
  end

  def self.instance=(_instance)
    @instance = _instance
  end

  def self.instance
    @instance
  end
end

class Config
  class Parser
    def initialize(config_file, parent)
      if File.exists?(config_file) && File.file?(config_file)
        @file = File.open(config_file, 'r').each do |line|
          next if line.strip.length == 0
          splitted_line = line.split(" ")
          key  = splitted_line.first
          value= splitted_line[1..splitted_line.count-1].join(" ")

          parent.set(key, value)
        end
      end

      parent.config_loaded = true
    end
  end
end
