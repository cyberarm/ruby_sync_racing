module AbstractJSON
  def self.dump(object)
    JSON.generate(object)
  end

  def self.load(string)
    JSON.parse(string)
  end
end
