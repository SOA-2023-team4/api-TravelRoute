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

  describe 'Generate Plan' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should able to generate a plan' do
      nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
      TravelRoute::Repository::Attractions.update_or_create(nthu)
      zoo = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Hsinchu zoo').first
      TravelRoute::Repository::Attractions.update_or_create(zoo)
      taipei_main = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Taipei Main Station').first
      TravelRoute::Repository::Attractions.update_or_create(taipei_main)

      correct_order = [nthu, zoo, taipei_main]
      cart = TravelRoute::Request::PlanGenerate.to_request(0, correct_order.map(&:place_id))

      result = TravelRoute::Service::GeneratePlan.new.call(cart)

      _(result.success?).must_equal true
      _(result.value!.message.attractions).must_equal correct_order
    end
  end
end
