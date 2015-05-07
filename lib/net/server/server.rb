module Game
  class Server
    attr_reader :server
    def initialize(host, port)
      @server = GameOverseer.activate(host, port)
      p @server
    end
  end
end
