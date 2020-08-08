# frozen_string_literal: false

require 'socket'

# turns requests to server into request objects
class Request
  attr_reader :method, :path, :query
  def initialize(request)
    parse_request(request)
  end

  private

  def parse_request(request)
    parsed_request = request.split(' ')
    @method = parsed_request[0]
    @path, @query = parsed_request[1].split('?')
  end
end

# crafts a response based on a Request object
class Response
  def initialize(request)
    @response = if request.method == 'GET'
                  if File.exist?("www#{request.path}")
                    get_response(request.path)
                  else
                    "HTTP/1.1 404 Resource Could Not Be Located\r\nContent-length: 0\r\n\r\n"
                  end
                else
                  "HTTP/1.1 400 Bad Request\r\nContent-length: 0\r\n\r\n"
                end
  end

  def to_s
    @response
  end

  private

  def get_response(path)
    body = File.read("www#{path}")
    status_line = "HTTP/1.1 200 OK\r\n"
    header = "Content-type: text/html; charset utf-8\r\nContent-length: #{body.length}\r\n\r\n"
    status_line + header + body
  end
end

server = TCPServer.new('localhost', 8080)

loop do
  Thread.start(server.accept) do |client|
    request = Request.new(client.gets)
    response = Response.new(request)
    client.puts response
    client.close
  end
end
