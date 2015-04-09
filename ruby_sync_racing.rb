require 'bundler/setup'
require "pp"
require "set"

require "chingu"
require "multi_json"
require "chipmunk"

require_relative "lib/engine" # require all the things.

if not defined?(Ocra)
  unless ARGV.join.include?("--editor")
    Display.new(1280, 800, false).show
  else
    Track::Editor::Window.new.show
  end
else
  puts "Ocra detected,", "Not running game."
end
