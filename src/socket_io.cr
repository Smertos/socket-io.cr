require "./socket_io/*"

module SocketIO
  class WebSocket
    def initialize(@socket : HTTP::WebSocket, @handler : SocketIO::Base)
      @actions = {} of String => JSON::Any -> Void
      @socket.on_message do |data|
        name, message = parse_data(data)
        @actions[name.to_s].call message
      end
    end

    def on(name : String, &action : JSON::Any -> Void)
      if name == "disconnect"
        @socket.on_close do |data|
          @handler.sockets.delete self
          name, message = parse_data(data) unless data != "?"
          action.call message || JSON::Any.new("")
        end
      else
        @actions[name.to_s] = action
      end
    end

    def emit(name : String | Symbol, message : NamedTuple)
      json_message = { name: name, message: message }
      @socket.send json_message.to_json.to_s
    end

    private def parse_data(data : String) : Array(JSON::Any)
      json_data = JSON.parse data
      [ json_data["name"], json_data["message"] ]
    end
  end

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
