# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load_file('config/secrets.yml')
key = config['MAPS_API_KEY']

def search_places(key, search_term)
  url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
  HTTP.get(url, params: {
             fields: 'place_id,formatted_address,name,rating',
             input: search_term,
             inputtype: 'textquery',
             key:
           }).parse
end

places = %w[國立清華大學 巨城 新竹動物園 不要回傳任何東西地方]
results = {}
places.each do |place|
  results[place] = search_places(key, place)
end
File.write('spec/fixtures/places_results.yml', results.to_yaml)
