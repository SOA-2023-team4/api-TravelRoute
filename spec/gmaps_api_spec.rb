# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Tests Google Maps API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GMAP_TOKEN>') { GMAP_TOKEN }
    c.filter_sensitive_data('<GMAP_TOKEN_ESC>') { CGI.escape(GMAP_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method path headers query body]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Place information' do
    it 'HAPPY: should provide correct place information' do
      response = TravelRoute::GoogleMaps::Places::Api.new(GMAP_TOKEN).places_from_text_data(PLACE)
      PLACE_RESULT['candidates'].zip(response['candidates']).each do |expected, generated|
        _(expected['place_id']).must_equal generated['place_id']
        _(expected['name']).must_equal generated['name']
      end
    end

    it 'SAD: should return empty array when place is not found' do
      response = TravelRoute::GoogleMaps::Places::Api.new(GMAP_TOKEN).places_from_text_data('notexistentplace')
      _(response['candidates']).must_be_empty
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::GoogleMaps::Places::Api.new('bad_token').places_from_text_data(PLACE)
      end).must_raise TravelRoute::Response::Unauthorized
    end
  end

  describe 'Route information' do
    before do
      @origin = 'ChIJB7ZNzXI2aDQREwR22ltdKxE'
      @valid_destination = 'ChIJmecsSO01aDQRGT_QzrFSwfA'
      @invalid_destination = 'invaliddestinationId'
    end

    it 'HAPPY: should provide correct route information' do
      response = TravelRoute::GoogleMaps::Routes::Api.new(GMAP_TOKEN).route_data(@origin, @valid_destination)
      _(response['routes']).wont_be_empty
    end

    it 'SAD: should raise exception when route not found' do
      _(proc do
        TravelRoute::GoogleMaps::Routes::Api.new(GMAP_TOKEN).route_data(@origin, @invalid_destination)
      end).must_raise TravelRoute::Response::BadRequest
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::GoogleMaps::Routes::Api.new('bad_token').route_data(@origin, @valid_destination)
      end).must_raise TravelRoute::Response::BadRequest
    end
  end
end
