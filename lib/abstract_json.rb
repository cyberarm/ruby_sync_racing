module AbstractJSON
  begin
    OJ_AVAILABLE = true
    require "oj"
  rescue LoadError => exception
    OJ_AVAILABLE = false
    require "json"
  end

  def self.dump(object)
    if OJ_AVAILABLE
      Oj.dump(object)
    else
      JSON.dump(object)
    end
  end
  
  def self.load(string)
    if OJ_AVAILABLE
      Oj.load(string)
    else
      JSON.parse(string)
    end
  end
end
