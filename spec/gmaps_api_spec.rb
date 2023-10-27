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
      expected = PLACE_DETAIL_RESULT['result']
      response = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find(PLACE)
      response.each do |generated|
        _(generated.id).must_equal expected['place_id']
        _(generated.name).must_equal expected['name']
      end
    end

    it 'SAD: should return empty array when place is not found' do
      response = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('notexistentplace')
      _(response).must_be_empty
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::PlaceMapper.new('bad_token').find(PLACE)
      end).must_raise TravelRoute::Response::Unauthorized
    end
  end

  describe 'Route information' do
    before do
      @origin = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('清大').first
      @valid_destination = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('Nanda Campus').first
      @invalid_destination = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('invaliddestinationId').first
    end

    it 'HAPPY: should provide correct route information' do
      response = TravelRoute::RouteMapper.new(GMAP_TOKEN).calculate_route(@origin, @valid_destination)
      _(response).wont_be_nil
      _(response.origin.id).must_equal @origin.id
      _(response.destination.id).must_equal @valid_destination.id
    end

    it 'SAD: should raise exception when route not found' do
      _(proc do
        TravelRoute::RouteMapper.new(GMAP_TOKEN).calculate_route(@origin, @invalid_destination)
      end).must_raise TravelRoute::Response::BadRequest
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::RouteMapper.new('bad_token').calculate_route(@origin, @valid_destination)
      end).must_raise TravelRoute::Response::BadRequest
    end
  end

  describe 'Route Matrix information' do
    before do
      @nthu = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('清大').first
      @zoo = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('Hsinchu zoo').first
      @big_city = TravelRoute::PlaceMapper.new(GMAP_TOKEN).find('Big City').first

      @places = [@nthu, @zoo, @big_city].shuffle
      @correct_order = [@nthu, @zoo, @big_city]
      @waypoints = TravelRoute::WaypointMapper.new(GMAP_TOKEN).waypoints(@places)
    end

    it 'HAPPY: should return nearest destination' do
      nearest = @waypoints.nearest_from(@nthu)
      _(nearest.origin.name).must_equal @nthu.name
      _(nearest.origin.id).must_equal @nthu.id
      _(nearest.destination.name).must_equal @zoo.name
      _(nearest.destination.id).must_equal @zoo.id
    end

    it 'HAPPY: should return correct route' do
      travel_place = @waypoints.travel_plan_from(@nthu)
      _(travel_place.size).must_equal @places.size - 1
      travel_place.each_with_index do |r, i|
        _(r.origin.name).must_equal @correct_order[i].name
        _(r.origin.id).must_equal @correct_order[i].id
        _(r.destination.name).must_equal @correct_order[i + 1].name
        _(r.destination.id).must_equal @correct_order[i + 1].id
      end
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::WaypointMapper.new('bad_token').waypoints(@places)
      end).must_raise TravelRoute::Response::BadRequest
    end
  end
end
