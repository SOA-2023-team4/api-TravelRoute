# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load_file('config/secrets.yml')
key = config['MAPS_API_KEY']

def headers(key)
  HTTP.headers(
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': key,
    'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
  )
end

def get_route(key, source_id, destination_id)
  url = 'https://routes.googleapis.com/directions/v2:computeRoutes'
  headers(key).post(url, 'json': {
                      'origin': { 'placeId': source_id },
                      'destination': { 'placeId': destination_id },
                      'routingPreference': 'TRAFFIC_AWARE',
                      'travelMode': 'DRIVE'
                    }).parse
end

origin_dest_pair = [
  %w[ChIJB7ZNzXI2aDQREwR22ltdKxE ChIJQyv318Q1aDQRYz_krC4mdb4],
  %w[ChIJB7ZNzXI2aDQREwR22ltdKxE ChIJl78Wnt01aDQRz1shOsBVUGU],
  %w[ImAIdthatdoesntexist ChIJl78Wnt01aDQRz1shOsBVUGU]
]
results = {}
origin_dest_pair.each { |origin, dest| results["#{origin}|#{dest}"] = get_route(key, origin, dest) }
File.write('spec/fixtures/routes_results.yml', results.to_yaml)
