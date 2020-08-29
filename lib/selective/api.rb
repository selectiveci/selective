require "net/http"
require "json"

module Selective
  module Api
    HOST = 'http://host.docker.internal:3000'

    def self.request(path, body=nil, method: :get)
      uri = URI.parse("#{HOST}/api/v1/#{path}")
      headers = { :'Content-Type' => 'application/json', 'X-API-KEY' => Selective.config.api_key }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      if method == :get
        request = Net::HTTP::Get.new(uri.request_uri, headers)
      elsif method == :post
        request = Net::HTTP::Post.new(uri.request_uri, headers)
      else
        raise 'Invalid method'
      end
      request.body = body.to_json if body.present?

      # Send the request
      response = http.request(request)

      # Parse response
      JSON.parse(response.body) if response.body.present?
    end
  end
end
