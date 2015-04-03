class Car
  class Parser
    def initialize(filename = "")
      if File.exist?(filename)
        return MultiJson.load(open(filename).read)
      else
        raise "#{self.class}: 'filename' is not a file!"
      end
    end
  end
end
