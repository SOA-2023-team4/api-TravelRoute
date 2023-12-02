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

  describe 'Attractions to database functionality' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to add an attraction and save to database' do
      nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      parsed = TravelRoute::Request::Attraction.to_request(nthu.to_attr_hash)
      result = TravelRoute::Service::AddAttraction.new.call(parsed)

      _(result.success?).must_equal true
      attraction = result.value!.message
      _(attraction).must_be_kind_of TravelRoute::Entity::Attraction
      _(attraction.place_id).must_equal nthu.place_id
      _(attraction.name).must_equal nthu.name
      _(attraction.address).must_equal nthu.address
      _(attraction.rating).must_equal nthu.rating
    end

    it 'HAPPY: should find and return existing attraction' do
      bigcity = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('bigcity').first
      parsed = TravelRoute::Request::Attraction.to_request(bigcity.to_attr_hash)
      new_rec = TravelRoute::Service::AddAttraction.new.call(parsed).value!

      dup_rec = TravelRoute::Service::AddAttraction.new.call(parsed)

      _(dup_rec.success?).must_equal true
      attraction = dup_rec.value!.message
      _(attraction).must_be_kind_of TravelRoute::Entity::Attraction
      _(attraction).must_equal new_rec.message
    end
  end
end
