require 'bundler/setup'
require "pp"
require "set"

require "chingu"
require "oj"
# require "chipmunk"
require "gameoverseer/version"
require "gameoverseer/client"

require_relative "lib/engine" # require all the things.
Vector2D = Struct.new(:x, :y)
Vector3D = Struct.new(:x, :y, :z)

if not defined?(Ocra)
  if ARGV.join.include?("--editor")
    Track::Editor::Window.new.show
  elsif ARGV.join.include?("--help")
    puts "Ruby Sync Racing version: #{Game::VERSION}"
    puts
    puts "Launch track editor:"
    puts "ruby #{__FILE__} --editor"
    puts
    puts "Show help:"
    puts "ruby #{__FILE__} --help"
  else
    Game::Display.new.show

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
