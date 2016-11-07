require 'bundler/setup'
require "pp"
require "set"

require "multi_json"
begin
  require "gameoverseer"
rescue
  require "../rewrite-gameoverseer/lib/gameoverseer"
end

require_relative "lib/net/server/server"
require_relative "lib/net/server/services/lobby"
require_relative "lib/net/server/services/auth"
require_relative "lib/net/server/services/game"
Game::Server.new('localhost', 56789)
