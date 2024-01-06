# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Test plan generation' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_gmap
    DatabaseHelper.wipe_database

    @nthu = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('清大').first
    @zoo = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Hsinchu zoo').first
    @taipei_main = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('Taipei Main Station').first

    @attractions = [@nthu, @taipei_main, @zoo]
    @distance_calculator = TravelRoute::Mapper::DistanceCalculatorMapper.new(GMAP_TOKEN).distance_calculator_for(@attractions)
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should be able to generate a correct plan' do
    @planner = TravelRoute::Entity::Planner.new(@attractions, @distance_calculator)
    generated_plans = @planner.generate_plans(
      [[TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 18, minute: 0)]],
      '2024-01-01', '2024-01-01'
    )
  end
end
