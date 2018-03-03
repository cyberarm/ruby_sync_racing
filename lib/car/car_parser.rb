class CarParser
  attr_accessor :data
  def initialize(filename = "")
    if File.exist?(filename)
      @data = AbstractJSON.load(open(filename).read)
    else
      raise "#{self.class}: '#{filename}' is not a file!"
    end
  end
end
