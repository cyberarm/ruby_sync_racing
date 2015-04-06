require "bundler"
require "pp"
require "set"

Bundler.require

require_relative "lib/engine" # require all the things.

unless ARGV.join.include?("--editor")
  Display.new(1280, 800, false).show
else
  Track::Editor.new.show
end
