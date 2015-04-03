require "bundler"
require "pp"
require "matrix"

Bundler.require

require_relative "lib/engine" # require all the things.

Display.new(1280, 800, false).show
