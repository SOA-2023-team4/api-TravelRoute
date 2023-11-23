# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Service integration testing' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_gmap
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'List attractions' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to list all attractions' do
      api_nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      api_zoo = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Hsinchu zoo').first

      db_nthtu = TravelRoute::Repository::Attractions.update_or_create(api_nthu)
      db_zoo = TravelRoute::Repository::Attractions.update_or_create(api_zoo)

      cart = [api_nthu.place_id, api_zoo.place_id]
      result = TravelRoute::Service::ListAttractions.new.call(cart)

      _(result.success?).must_equal true
      attractions = result.value!
      _(attractions.length).must_equal 2
      _(attractions.first).must_equal db_nthtu
      _(attractions.last).must_equal db_zoo
    end

    it 'HAPPY: should not return attractions that is not in the cart' do
      api_nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      TravelRoute::Repository::Attractions.update_or_create(api_nthu)

      cart = []
      result = TravelRoute::Service::ListAttractions.new.call(cart)

      _(result.success?).must_equal true
      attractions = result.value!
      _(attractions.length).must_equal 0
      _(attractions).must_be_empty
    end

    it 'SAD: should report if no attractions are found locally' do
      cart = [BIGCITY_PLACE_ID]
      result = TravelRoute::Service::ListAttractions.new.call(cart)

      _(result.failure?).must_equal false
      attractions = result.value!
      _(attractions).must_equal [nil]
    end
  end
end
