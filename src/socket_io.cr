require "./socket_io/*"

module SocketIO
  class WebSocket
    def initialize(@socket : HTTP::WebSocket)
      @actions = {} of String => JSON::Any -> Void
      @socket.on_message do |data|
        name, message = parse_data(data)
        @actions[name.to_s].call message
      end
    end

    def on(name : String, &action : JSON::Any -> Void)
      if name == "disconnect"
        @socket.on_close do |data|
          name, message = parse_data(data)
          action.call message
        end
      else
        @actions[name.to_s] = action
      end
    end

    private def parse_data(data : String) : Array(JSON::Any)
      json_data = JSON.parse data
      [ json_data["name"], json_data["message"] ]
    end
  end

  class Base
    def initialize
      @sockets = [] of HTTP::WebSocket
    end

    def on_connection(&action : WebSocket -> Void) : HTTP::WebSocketHandler
      HTTP::WebSocketHandler.new do |session|
        @sockets << session
        action.call WebSocket.new(session)
      end
    end

    def emit(name : String | Symbol, message : Hash)
      json_message = { name: name, message: message }
      @sockets.each { |socket| socket.send json_message.to_json.to_s }
    end
  end
end
