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
  end
end
