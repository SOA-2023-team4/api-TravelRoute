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
      bus_station = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Hsinchu Bus station').first
      TravelRoute::Repository::Attractions.update_or_create(bus_station)
      taipei_main = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Taipei Main Station').first
      TravelRoute::Repository::Attractions.update_or_create(taipei_main)

      correct_order = [nthu, bus_station, taipei_main]
      shuffle_order = correct_order.shuffle
      cart = TravelRoute::Request::PlanGenerate.to_request(
        shuffle_order.index(nthu),
        shuffle_order.map(&:place_id),
        '2023-01-10',
        '2023-01-11'
      )

      result = TravelRoute::Service::GeneratePlan.new.call(plan_req: cart)

      _(result.success?).must_equal true
      # result.value!.message.attractions.each_with_index do |attraction, index|
      #   _(attraction.place_id).must_equal correct_order[index].place_id
      #   _(attraction.name).must_equal correct_order[index].name
      #   _(attraction.location.longitude).must_equal correct_order[index].location.longitude
      #   _(attraction.location.latitude).must_equal correct_order[index].location.latitude
      #   _(attraction.type).must_equal correct_order[index].type
      # end
    end
  end
end
