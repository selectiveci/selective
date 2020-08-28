module Selective
  module Api
    HOST = 'http://host.docker.internal:3000'
    
    def self.request(path, body=nil)
      uri = URI.parse("#{HOST}/api/v1/#{path}")
      headers = { :'Content-Type' => 'application/json', 'X-API-KEY' => Selective.config.api_key }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      request.body = body.to_json if body.present?

      # Send the request
      response = http.request(request)

      # Parse response
      JSON.parse(response.body) if response.present?
    end
  end
end
