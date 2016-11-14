begin
  require_all 'lib'
rescue NameError => e
  p e
end

module Engine
  def self.timestamp
    Time.now.to_f*1000.0
  end
end
