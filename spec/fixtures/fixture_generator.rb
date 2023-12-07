# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load_file('../config/secrets.yml')
key = config['test']['GMAP_TOKEN']
FIELDS = %w[id displayName formattedAddress rating regularOpeningHours primaryType location].freeze
headers = {
  'Content-Type': 'application/json',
  'X-Goog-Api-Key': key,
  'X-Goog-FieldMask': FIELDS.join(',')
}

results = {}
nthu_place_id = 'ChIJB7ZNzXI2aDQREwR22ltdKxE'
url = "https://places.googleapis.com/v1/places/#{nthu_place_id}"
results['nthu'] = HTTP.headers(headers).get(url).parse

big_city_place_id = 'ChIJQyv318Q1aDQRYz_krC4mdb4'
url = "https://places.googleapis.com/v1/places/#{big_city_place_id}"
results['bigcity'] = HTTP.headers(headers).get(url).parse

zoo_place_id = 'ChIJl78Wnt01aDQRz1shOsBVUGU'
url = "https://places.googleapis.com/v1/places/#{zoo_place_id}"
results['HsinchuZoo'] = HTTP.headers(headers).get(url).parse

File.write('place_detail.yml', results.to_yaml)
