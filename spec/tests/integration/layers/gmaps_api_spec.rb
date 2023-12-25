# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'

describe 'Tests Google Maps API library' do
  before do
    VcrHelper.setup_vcr
    VcrHelper.configure_vcr_for_gmap
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Place information' do
    it 'HAPPY: should provide correct place when searching by text' do
      expected = PLACE_DETAIL_RESULT['nthu']
      response = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find(PLACE)
      _(response.map(&:place_id)).must_include expected['id']
    end

    it 'HAPPY: should provide correct place when searching by id' do
      expected = PLACE_DETAIL_RESULT['bigcity']
      response = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find_by_id(BIGCITY_PLACE_ID)
      _(response.place_id).must_equal expected['id']
      _(response.name).must_equal expected['displayName']['text']
      _(response.address).must_equal expected['formattedAddress']
    end

    it 'SAD: should return empty array when place is not found' do
      response = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('notexistentplace')
      _(response).must_be_empty
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::Mapper::AttractionMapper.new('bad_token').find(PLACE)
      end).must_raise TravelRoute::Http::Response::BadRequest
    end
  end

  describe 'Route information' do
    before do
      @origin = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      @valid_destination = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Nanda Campus').first
      @invalid_destination = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('invaliddestinationId').first
    end

    it 'HAPPY: should provide correct route information' do
      response = TravelRoute::Mapper::RouteMapper.new(GMAP_TOKEN).calculate_route(@origin, @valid_destination)
      _(response).wont_be_nil
      _(response.origin.place_id).must_equal @origin.place_id
      _(response.destination.place_id).must_equal @valid_destination.place_id
    end

    it 'SAD: should raise exception when route not found' do
      _(proc do
        TravelRoute::Mapper::RouteMapper.new(GMAP_TOKEN).calculate_route(@origin, @invalid_destination)
      end).must_raise TravelRoute::Http::Response::BadRequest
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        TravelRoute::Mapper::RouteMapper.new('bad_token').calculate_route(@origin, @valid_destination)
      end).must_raise TravelRoute::Http::Response::BadRequest
    end
  end

  describe 'Guidebook information' do
    before do
      @nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      @zoo = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Hsinchu zoo').first
      @taipei_main = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Taipei Main Station').first

      @attractions = [@nthu, @taipei_main, @zoo]
    end

    it 'HAPPY: should return correct guidebook' do
      guidebook = TravelRoute::Mapper::GuidebookMapper.new(GMAP_TOKEN).generate_guidebook(@attractions)
      _(guidebook.attractions.count).must_equal(guidebook.distance_matrix.count)
    end
  end
end
