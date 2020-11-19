require_all Dir.glob("lib/**/*.rb").reject { |f| f.include?("server/") or f.include?("net/") }

module Engine
  def self.timestamp
    Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
  end
end
