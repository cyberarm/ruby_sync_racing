require 'bundler/setup'
require "pp"
require "set"

require "multi_json"
begin
  require "../rewrite-gameoverseer/lib/gameoverseer"
rescue
  require "gameoverseer"
end

require_relative "lib/net/server/server"
require_relative "lib/net/server/services/lobby"
require_relative "lib/net/server/services/auth"
Game::Server.new('localhost', 56789)
