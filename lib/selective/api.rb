require "net/http"
require "json"

module Selective
  module Api
    def self.request(path, body = nil, method: :get)
      uri = URI.parse("#{Selective.config.backend_host}/api/v1/#{path}")
      headers = {:"Content-Type" => "application/json", "X-API-KEY" => Selective.config.api_key}

      # Create the HTTP objects
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http|
        request = case method
          when :get
            Net::HTTP::Get.new(uri.request_uri, headers)
          when :post
            Net::HTTP::Post.new(uri.request_uri, headers)
          else
            raise "Invalid method"
        end

        if body.present?
          request.body = body.to_json
        end

        # Send the request
        http.request(request)
      }

      # Parse response
      if response.body.present?
        JSON.parse(response.body)
      end
    end
  end
end
