require "pp"
require "set"

require "gosu"
# require "chipmunk"
require "gameoverseer/version"
require "gameoverseer/client"

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/require_all"
require_relative "lib/engine" # require all the things.

if not defined?(Ocra)
  Config.ensure_config_exists
  Config.new("./data/config.ini")

  Window.new.show

  at_exit do
    @client = Game::Net::Client.instance
    if @client
      @client.disconnect
    end
  end
else
  puts "Ocra detected,", "Not running game."
end
