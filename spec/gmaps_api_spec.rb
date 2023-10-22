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
        end
      end
    end

    it 'SAD: should return empty array when place is not found' do
      _(TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).place_matches('idoesntexist')).must_be_empty
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

  describe 'Route Matrix information' do
    before do
      @nthu = TravelRoute::Place.new(PLACE_RESULT[PLACES[0]]['matches'][0])
      @zoo = TravelRoute::Place.new(PLACE_RESULT[PLACES[2]]['matches'][0])
      @big_city = TravelRoute::Place.new(PLACE_RESULT[PLACES[1]]['matches'][0])

      @places = [@nthu, @zoo, @big_city]
    end

    it 'HAPPY: should return nearest destination' do
      matrix = TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).get_route_matrix(@places)
      _(matrix.nearest_from(@nthu).origin.name).must_equal @nthu.name
      _(matrix.nearest_from(@nthu).origin.id).must_equal @nthu.id
      _(matrix.nearest_from(@nthu).destination.name).must_equal @zoo.name
      _(matrix.nearest_from(@nthu).destination.id).must_equal @zoo.id
    end

    it 'HAPPY: should return correct route' do
      matrix = TravelRoute::GoogleMapsApi.new(GMAP_TOKEN).get_route_matrix(@places)
      route = matrix.construct_route_from(@nthu)
      _(route.size).must_equal @places.size - 1
      route.each_with_index do |r, i|
        _(r.origin.name).must_equal @places[i].name
        _(r.origin.id).must_equal @places[i].id
        _(r.destination.name).must_equal @places[i + 1].name
        _(r.destination.id).must_equal @places[i + 1].id
      end
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::GoogleMapsApi.new('bad_token').get_route_matrix(@places)
      end).must_raise TravelRoute::ApiResponse::Errors::Unauthorized
    end
  end
end
