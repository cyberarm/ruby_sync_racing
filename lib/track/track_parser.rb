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
    end

    def checkpoints
    end
  end
end
