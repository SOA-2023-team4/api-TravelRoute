# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'yaml'
require 'vcr'
require 'webmock'

require_relative '../../require_app'
require_app

GMAP_TOKEN = TravelRoute::App.config.GMAP_TOKEN

PLACE = '清大'
BIGCITY_PLACE_ID = 'ChIJQyv318Q1aDQRYz_krC4mdb4'
PLACE_RESULT = YAML.safe_load_file('spec/fixtures/places_from_text.yml')
PLACE_DETAIL_RESULT = YAML.safe_load_file('spec/fixtures/place_detail.yml')
ROUTE_RESULT = YAML.safe_load_file('spec/fixtures/route_data.yml')
