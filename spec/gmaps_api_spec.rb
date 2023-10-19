# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/gmaps_api'

CONFIG = YAML.safe_load_file('config/secrets.yml')
GMAP_TOKEN = CONFIG['MAPS_API_KEY']
PLACE_RESULT = YAML.safe_load_file('spec/fixtures/places_results.yml')
PLACES = %w[國立清華大學 巨城 新竹動物園].freeze
ROUTE_RESULT = YAML.safe_load_file('spec/fixtures/routes_results.yml')

describe 'Tests Google Maps API library' do
  describe 'Place information' do
    it 'HAPPY: should provide correct place information' do
      PLACES.each do |place|
        query = TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).place_matches(place)
        PLACE_RESULT[place]['matches'].each_with_index do |p, index|
          _(query[index].id).must_equal p['place_id']
          _(query[index].name).must_equal p['name']
          _(query[index].formatted_address).must_equal p['formatted_address']
          _(query[index].rating).must_equal p['rating']
        end
      end
    end

    it 'SAD: should be raise eception when place not found' do
      _(proc do
        TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).place_matches('ImAIdthatdoesntexist')
      end).must_raise TravelRoute::GoogleMapsApi::Errors::PlaceNotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::GoogleMapsApi.new('bad_token').place_matches(PLACES[0])
      end).must_raise TravelRoute::ApiResponse::Errors::RequestDenied
    end
  end

  describe 'Route information' do
    before do
      @origin = TravelRoute::Place.new(PLACE_RESULT[PLACES[0]]['matches'][0])
      @valid_destination = TravelRoute::Place.new(PLACE_RESULT[PLACES[1]]['matches'][0])
      @invalid_destination = TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).place_matches('Rio de Janeiro')[0]
    end

    it 'HAPPY: should provide correct route information' do
      route = TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).get_routes(@origin, @valid_destination)
      route.each do |r|
        _(r.origin.name).must_equal @origin.name
        _(r.origin.id).must_equal @origin.id
        _(r.destination.name).must_equal @valid_destination.name
        _(r.destination.id).must_equal @valid_destination.id
        _(r.distance_meters).must_be_kind_of Integer
        _(r.duration).must_be_kind_of String
      end
    end

    it 'SAD: should raise exception when route not found' do
      _(proc do
        TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).get_routes(@origin, @invalid_destination)
      end).must_raise TravelRoute::GoogleMapsApi::Errors::RouteNotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::GoogleMapsApi.new('bad_token').get_routes(@origin, @valid_destination)
      end).must_raise TravelRoute::ApiResponse::Errors::Unauthorized
    end
  end
end
