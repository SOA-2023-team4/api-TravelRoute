# frozen_string_literal: true

module TravelRoute
  # Contains logic about http request
  class Request
    def self.get(url, headers)
      http_response = HTTP.headers(headers).get(url)
      Response.new(http_response).tap do |response|
        raise(response.error) unless response.successful?
      end
    end

    def self.post(url, headers, body)
      http_response = HTTP.headers(headers).post(url, json: body)
      Response.new(http_response).tap do |response|
        raise(response.error) unless response.successful?
      end
    end
  end
end
