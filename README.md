# SocketIO

Small analog socket.io

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  socket_io:
    github: forsaken1/socket-io.cr
```


## Usage

With [Kemal](http://kemalcr.com):

```crystal
require "kemal"
require "socket_io"

socket_io = SocketIO::Base.new

handler = socket_io.on_connection do |session| # session : SocketIO::WebSocket
  session.on("client_event") do |message|
    puts message
  end
end

socket_io.emit :tick, { array: [1, 2, 3, 4], hash: { field: "Field" } } # send to all client

Kemal.config.add_handler handler
Kemal.run
```


## On client

Use JS analog [SocketIO.js](https://gist.github.com/forsaken1/6223ed86422c0996634b)


## Contributing

1. Fork it ( https://github.com/forsaken1/socket-io.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [forsaken1](https://github.com/forsaken1) Krylov Alexey - creator, maintainer
