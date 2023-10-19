# frozen_string_literal: true

require 'http'
require_relative 'place'
require_relative 'route'
require_relative 'route_matrix'
require_relative 'api_response'

module TravelRoute
  # Library for Google Maps API
  class GoogleMapsApi
    API_PLACE_ROOT = 'https://maps.googleapis.com/maps/api/place'
    API_ROUTE_ROOT = 'https://routes.googleapis.com'

    module Errors
      # Error for place not found
      class PlaceNotFound < StandardError; end

      # Error for route not found
      class RouteNotFound < StandardError; end
    end

    def initialize(api_key)
      @key = api_key
      @headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': @key
      }
    end

    def place_matches(search_term)
      url = place_api_path('findplacefromtext/json')
      params = request_params(%w[place_id], params: { input: search_term, inputtype: 'textquery' })
      response = call_get_api(url, params:)
      raise ApiResponse::Errors::RequestDenied unless response.successful?

      places = response.body['candidates']
      raise Errors::PlaceNotFound if places.empty?

      places_detail(places.map { |place| place['place_id'] })
    end

    def places_detail(places_id)
      url = place_api_path('details/json')
      places_id.map do |place_id|
        params = request_params(%w[name place_id formatted_address rating], params: { place_id: })
        place_data = call_get_api(url, params:).body['result']
        Place.new(place_data)
      end
    end

    def get_routes(origin, destination)
      url = route_api_path('directions/v2:computeRoutes')
      @headers['X-Goog-FieldMask'] = 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
      json = request_body({
                            origin: { placeId: origin.id },
                            destination: { placeId: destination.id }
                          })
      response = call_post_api(url, json:).body
      raise Errors::RouteNotFound unless response.key?('routes')

      parse_route(response, origin, destination)
    end

    def get_route_matrix(places)
      url = route_api_path('distanceMatrix/v2:computeRouteMatrix')
      @headers['X-Goog-FieldMask'] = 'originIndex,destinationIndex,duration,distanceMeters,status'
      json = request_body({
                            origins: places.map { |p| { waypoint: { place_id: p.id } } },
                            destinations: places.map { |p| { waypoint: { place_id: p.id } } }
                          })
      response = call_post_api(url, json:).body

      RouteMatrix.new(response, places)
    end

    private

    def place_api_path(path)
      "#{API_PLACE_ROOT}/#{path}"
    end

    def request_params(fields, params: nil)
      {
        fields: fields.join(','),
        key: @key
      }.merge(params)
    end

    def request_body(body)
      {
        routingPreference: 'TRAFFIC_AWARE',
        travelMode: 'DRIVE'
      }.merge(body)
    end

    def route_api_path(path)
      "#{API_ROUTE_ROOT}/#{path}"
    end

    def call_post_api(url, json: nil)
      response = HTTP.headers(@headers).post(url, json:)
      ApiResponse.new(response)
    end

    def call_get_api(url, params: nil)
      response = HTTP.get(url, params:)
      ApiResponse.new(response)
    end

    def parse_route(response, origin, destination)
      routes_data = response['routes']
      routes_data.map do |route_data|
        route_data['origin'] = origin
        route_data['destination'] = destination
        Route.new(route_data)
      end
    end
  end
end
