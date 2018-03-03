require_all Dir.glob("lib/**/*.rb").reject { |f| f.include?("server/") }

module Engine
  def self.timestamp
    Time.now.to_f*1000.0
  end
end
