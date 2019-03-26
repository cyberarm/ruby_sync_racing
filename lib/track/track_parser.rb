class Track
  class Parser
    attr_reader :data

    def initialize(trackfile)
      raise "#{self.class}: '#{trackfile}' is not a file." unless File.exist?(trackfile)
      @data = AbstractJSON.load(open(trackfile).read)
    end

    def tiles
      @data["tiles"]
    end

    def decorations
      @data["decorations"]
    end

    def checkpoints
      @data["checkpoints"]
    end

    def starting_positions
      @data["starting_positions"]
    end

    def background
      if @data.dig("background")
        _background = @data["background"]
        Gosu::Color.rgba(_background["red"], _background["green"], _background["blue"], _background["alpha"])
      else
        _color = Gosu::Color.rgba(100,254,78,144) # Soft, forest green.
      end
    end

    def time_of_day
      @data.dig("time_of_day")
    end
  end
end
