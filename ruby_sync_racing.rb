require 'bundler/setup'
require "pp"
require "set"

require "chingu"
require "multi_json"
require "chipmunk"
require "gameoverseer/version"
require "gameoverseer/client"

require_relative "lib/engine" # require all the things.

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
  end
else
  puts "Ocra detected,", "Not running game."
end
