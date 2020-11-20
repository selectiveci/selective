require "net/http"
require "json"

module Selective
  module Api
    def self.request(path, body = nil, method: :get)
      uri = URI.parse("#{Selective.config.backend_host}/api/v1/#{path}")
      headers = {:"Content-Type" => "application/json", "X-API-KEY" => Selective.config.api_key}

      # Create the HTTP objects
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http|
        if method == :get
          request = Net::HTTP::Get.new(uri.request_uri, headers)
        elsif method == :post
          request = Net::HTTP::Post.new(uri.request_uri, headers)
        else
          raise "Invalid method"
        end
        request.body = body.to_json if body.present?

        # Send the request
        http.request(request)
      }

      # Parse response
      JSON.parse(response.body) if response.body.present?
    end
  end
end
