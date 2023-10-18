# frozen_string_literal: true

require 'http'
require_relative 'place'
require_relative 'route'

module TravelRoute
  # Library for Google Maps API
  class GoogleMapsApi
    def initialize(api_key)
      @key = api_key
      @headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': @key,
        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
      }
    end

    def place_matches(search_term)
      url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
      response = HTTP.get(url, params: {
                            fields: 'place_id',
                            input: search_term,
                            inputtype: 'textquery',
                            key: @key
                          }).parse
      places = response['candidates']
      places_data = places.map { |place| place_detail(place['place_id']) }
      places_data.map { |place_data| Place.new(place_data) }
    end

    def place_detail(place_id)
      url = 'https://maps.googleapis.com/maps/api/place/details/json'
      HTTP.get(url, params: {
                 fields: 'name,place_id,formatted_address,geometry,opening_hours,rating,business_status',
                 place_id:,
                 key: @key
               }).parse['result']
    end

    def get_routes(origin, destination)
      url = 'https://routes.googleapis.com/directions/v2:computeRoutes'
      response = HTTP.headers(@headers).post(url, 'json': {
                                               'origin': { 'placeId': origin.id },
                                               'destination': { 'placeId': destination.id },
                                               'routingPreference': 'TRAFFIC_AWARE',
                                               'travelMode': 'DRIVE'
                                             }).parse
      return [] unless response.key?('routes')

      routes_data = response['routes']
      routes_data.map do |route_data|
        route_data['origin'] = { 'name' => origin.name, 'id' => origin.id }
        route_data['destination'] = { 'name' => destination.name, 'id' => destination.id }
        Route.new(route_data)
      end
    end
  end
end

require 'yaml'
config = YAML.safe_load_file('config/secrets.yml')
key = config['MAPS_API_KEY']
p1 = TravelRoute::GoogleMapsApi.new(key).place_matches('São Paulo')[0]
p2 = TravelRoute::GoogleMapsApi.new(key).place_matches('Rio de Janeiro')[0]
routes = TravelRoute::GoogleMapsApi.new(key).get_routes(p1, p2)
require 'pry'; binding.pry
