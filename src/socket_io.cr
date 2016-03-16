require "./socket_io/*"

module SocketIO
  class Base
    def initialize(@socket : HTTP::WebSocket)
      @actions = {} of String => (JSON::Any -> Void)
      socket.on_message do |data|
        name, message = parse_data(data)
        @actions[name.to_s].call message
      end
    end

    def emit(name : String | Symbol, message : Hash)
      json_message = { name: name, message: message }
      @socket.send json_message.to_json.to_s
    end

    def on(name : String, &action : JSON::Any -> Void)
      @actions[name] = action
    end

    private def parse_data(data : String) : Array(JSON::Any)
      json_data = JSON.parse data
      [json_data["name"], json_data["message"]]
    end
  end
end
