# frozen_string_literal: true

module TravelRoute
  # Class for api request
  class ApiRequest
    API_PLACE_ROOT = 'https://maps.googleapis.com/maps/api/place'
    API_ROUTE_ROOT = 'https://routes.googleapis.com'

    def initialize(api_key)
      @api_key = api_key
      @headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': @api_key
      }
      @body = {
        routingPreference: 'TRAFFIC_AWARE',
        travelMode: 'DRIVE'
      }
    end

    def get(url, params: nil)
      response = HTTP.headers(@headers).get(url, params:)
      ApiResponse.new(response)
    end

    def post(url, json: nil)
      response = HTTP.headers(@headers).post(url, json:)
      ApiResponse.new(response)
    end

    def headers(headers)
      @headers.merge!(headers)
      self
    end

    def request_params(fields, params: nil)
      {
        fields: fields.join(','),
        key: @api_key
      }.merge(params)
    end

    def request_body(body)
      @body.merge(body)
    end

    def self.place_api_path(path)
      "#{API_PLACE_ROOT}/#{path}"
    end

    def self.route_api_path(path)
      "#{API_ROUTE_ROOT}/#{path}"
    end
  end
end
