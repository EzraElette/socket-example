require 'socket'

server = TCPServer.new 'localhost', 8080

loop do
  Thread.start(server.accept) do |client|
    request = client.gets
    method, path, = request.split(' ')
    status, header, body = [''] * 3

    if method == 'GET'
      if File.exist?("./www#{path}")
        body = File.read("./www#{path}")
        status = "HTTP/1.1 200 OK\r\n"
        header = "Content-type: text/html\r\nContent-length: #{body.length}\r\n\r\n"
      else
        status = 'HTTP/1.1 404 File Not Found'
      end
    else
      status = 'HTTP/1.1 400 Bad Request'
    end
    client.puts(status + header + body)
    client.close
  end
end
