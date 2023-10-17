require 'http'
require_relative 'place'
require_relative 'route'

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
    place_ids = places.map{|place| place['place_id']}
    places_data = place_ids.map{|id| place_detail(id)}
    places_data.map{|place_data| Place.new(place_data)}
  end

  def place_detail(place_id)
    url = 'https://maps.googleapis.com/maps/api/place/details/json'
    HTTP.get(url, params: {
               fields: 'name,place_id,formatted_address,geometry,opening_hours,rating,business_status',
               place_id:,
               key: @key
             }).parse['result']
  end

  def get_routes(origin_id, destination_id)
    url = 'https://routes.googleapis.com/directions/v2:computeRoutes'
    response = HTTP.headers(@headers).post(url, 'json': {
                        'origin': { 'placeId': origin_id },
                        'destination': { 'placeId': destination_id },
                        'routingPreference': 'TRAFFIC_AWARE',
                        'travelMode': 'DRIVE'
                      }).parse
    return [] unless response.key?('routes')
    routes_data = response['routes']
    routes_data.map{|route_data|
      route_data['origin_id'] = origin_id
      route_data['destination_id'] = origin_id
      Route.new(route_data)
    }
  end
end