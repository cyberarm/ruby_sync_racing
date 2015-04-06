require "bundler"
require "pp"
require "set"

Bundler.require

require_relative "lib/engine" # require all the things.

Display.new(1280, 800, false).show
