# frozen_string_literal: true

require 'yaml'
require_relative 'gmaps_api'

config = YAML.safe_load_file('config/secrets.yml')
api = GoogleMapsApi.new(config['MAPS_API_KEY'])

searches = %w[國立清華大學 巨城 新竹動物園 不要回傳任何東西地方]
place_search_results = searches.map { |search| api.place_matches(search) }
place_search_results.each { |result| puts result.first.name unless result.empty? }

place_id_pairs = [
  %w[ChIJB7ZNzXI2aDQREwR22ltdKxE ChIJQyv318Q1aDQRYz_krC4mdb4],
  %w[ChIJB7ZNzXI2aDQREwR22ltdKxE ChIJl78Wnt01aDQRz1shOsBVUGU],
  %w[ImAIdthatdoesntexist ChIJl78Wnt01aDQRz1shOsBVUGU]
]
routes = place_id_pairs.map { |origin, dest| api.get_routes(origin, dest) }
routes.each { |route| puts route.first.distanceMeters unless route.empty? }
