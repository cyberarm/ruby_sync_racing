module AbstractJSON
  require "multi_json"

  def self.dump(object)
    MultiJson.dump(object)
  end

  def self.load(string)
    MultiJson.load(string)
  end
end
