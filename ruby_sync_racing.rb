if ARGV.join.include?("--debug")
  $debug = true
  puts "Debug mode"
else
  $debug = false
end
require "pp"
require "set"

require "gosu"
# require "chipmunk"
require "gameoverseer/version"
require "gameoverseer/client"

require_relative "lib/require_all"
require_relative "lib/engine" # require all the things.
Vector2D = Struct.new(:x, :y)
Vector3D = Struct.new(:x, :y, :z)

if not defined?(Ocra)
  if ARGV.join.include?("--editor")
    Config.ensure_config_exists
    Config.new("./data/config.ini")
    if ARGV.join.include?("--small")
      Track::Editor::Window.new(720, 480, false).show
    else
      Track::Editor::Window.new.show
    end
  elsif ARGV.join.include?("--help")
    puts "Ruby Sync Racing version: #{Game::VERSION}"
    puts
    puts "Launch track editor:"
    puts "ruby #{__FILE__} --editor"
    puts
    puts "Show help:"
    puts "ruby #{__FILE__} --help"
  else
    Config.ensure_config_exists
    Config.new("./data/config.ini")

    Display.new.show

    at_exit do
      @client = Game::Net::Client.instance
      if @client
        @client.disconnect
      end
    end
  end
else
  puts "Ocra detected,", "Not running game."
end
