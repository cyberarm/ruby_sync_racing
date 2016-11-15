require "pp"
require "set"
require "securerandom"

begin
  require "gameoverseer"
rescue
  require "../rewrite-gameoverseer/lib/gameoverseer"
end

require_relative "lib/abstract_json"
require_relative "lib/net/server/server"
require_relative "lib/net/server/services/lobby"
require_relative "lib/net/server/services/auth"
require_relative "lib/net/server/services/game"
Game::Server.new('localhost', 56789)
