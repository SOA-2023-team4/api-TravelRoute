# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'yaml'
require 'vcr'
require 'webmock'

require_relative '../lib/gmaps_api'

CONFIG = YAML.safe_load_file('config/secrets.yml')
GMAP_TOKEN = CONFIG['MAPS_API_KEY']
PLACE_RESULT = YAML.safe_load_file('spec/fixtures/places_results.yml')
PLACES = %w[國立清華大學 巨城 新竹動物園].freeze
ROUTE_RESULT = YAML.safe_load_file('spec/fixtures/routes_results.yml')
CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'gmaps_api'
