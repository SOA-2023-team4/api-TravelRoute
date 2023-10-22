# frozen_string_literal: true

require 'http'
require_relative 'place'
require_relative 'route'
require_relative 'route_matrix'
require_relative 'api_request'
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
      @request = ApiRequest.new(api_key)
    end

    def place_matches(search_term)
      url = ApiRequest.place_api_path('findplacefromtext/json')
      params = @request.request_params(%w[place_id], params: { input: search_term, inputtype: 'textquery' })
      response = @request.get(url, params:)
      raise ApiResponse::Errors::RequestDenied unless response.successful?

      places = response.body['candidates']
      places_detail(places.map { |place| place['place_id'] })
    end

    def places_detail(places_id)
      url = ApiRequest.place_api_path('details/json')
      places_id.map do |place_id|
        params = @request.request_params(%w[name place_id formatted_address rating], params: { place_id: })
        place_data = @request.get(url, params:).body['result']
        Place.new(place_data)
      end
    end

    def get_routes(origin, destination)
      url = ApiRequest.route_api_path('directions/v2:computeRoutes')
      json = @request.request_body({
                                     origin: { placeId: origin.id },
                                     destination: { placeId: destination.id }
                                   })
      response = @request.headers({ 'X-Goog-FieldMask':
                                      'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline' })
                         .post(url, json:).body
      raise Errors::RouteNotFound unless response.key?('routes')

      Route.parse_route(response, origin, destination)
    end

    def get_route_matrix(places)
      url = ApiRequest.route_api_path('distanceMatrix/v2:computeRouteMatrix')
      waypoints = places.map { |place| { waypoint: { placeId: place.id } } }
      json = @request.request_body({
                                     origins: waypoints,
                                     destinations: waypoints
                                   })
      response = @request.headers({ 'X-Goog-FieldMask':
                                      'originIndex,destinationIndex,duration,distanceMeters,status' })
                         .post(url, json:).body

      RouteMatrix.new(response, places)
    end
  end
end
