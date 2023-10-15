# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load_file('config/secrets.yml')
key = config['MAPS_API_KEY']

def headers(key)
  HTTP.headers(
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': key,
    'X-Goog-FieldMask': 'originIndex,destinationIndex,duration,distanceMeters,status'
  )
end

def get_route_matrix(key, places)
  url = 'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix'
  headers(key).post(url, 'json': {
                      'origins': waypoints(places),
                      'destinations': waypoints(places),
                      'travelMode': 'DRIVE'
                    }).parse
end

def waypoints(places)
  places.map { |p| { 'waypoint': { 'place_id': p } } }
end

def mapping_place_id_to_name(key, place_id)
  url = 'https://maps.googleapis.com/maps/api/place/details/json'
  response = HTTP.get(url, params: {
                        fields: 'name',
                        place_id:,
                        key:
                      }).parse['result']
  response.nil? ? 'InvalidPlace' : response['name']
end

def reorganize_response(response, index)
  response.select { |r| r['originIndex'] == index && r['destinationIndex'] != index }
end

places = %w[ChIJB7ZNzXI2aDQREwR22ltdKxE ChIJQyv318Q1aDQRYz_krC4mdb4 ChIJl78Wnt01aDQRz1shOsBVUGU ImAIdthatdoesntexist]

response = get_route_matrix(key, places)
results = {}

places.each_with_index do |origin_id, origin_index|
  results[origin_id] = reorganize_response(response, origin_index)
end

File.write('spec/fixtures/routes_matrix_results.yml', results.to_yaml)
