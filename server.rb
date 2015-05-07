require 'bundler/setup'
require "pp"
require "set"

require "chingu"
require "multi_json"
require "chipmunk"
require "gameoverseer/version"
require "gameoverseer"

require_relative "lib/engine" # require all the things.

Game::Server.new('localhost', 56789)
