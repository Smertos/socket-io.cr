module SocketIO
  class Base
    getter :sockets
    
    def initialize
      @sockets = [] of WebSocket
    end

    def on_connection(&action : WebSocket -> Void) : HTTP::WebSocketHandler
      HTTP::WebSocketHandler.new do |session|
        socket = WebSocket.new(session, self)
        @sockets << socket
        action.call socket
      end
    end

    def emit(name : String | Symbol, message : NamedTuple)
      @sockets.each { |socket| socket.emit name, message }
    end
  end
end
