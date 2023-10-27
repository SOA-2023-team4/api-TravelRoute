# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'yaml'
require 'vcr'
require 'webmock'

require_relative '../lib/gateways/places_api'
require_relative '../lib/gateways/routes_api'

CONFIG = YAML.safe_load_file('config/secrets.yml')
GMAP_TOKEN = CONFIG['MAPS_API_KEY']

PLACE = '清大'
PLACE_RESULT = YAML.safe_load_file('spec/fixtures/places_from_text.yml')
PLACE_DETAIL_RESULT = YAML.safe_load_file('spec/fixtures/place_detail.yml')
ROUTE_RESULT = YAML.safe_load_file('spec/fixtures/route_data.yml')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'gmaps_api'
