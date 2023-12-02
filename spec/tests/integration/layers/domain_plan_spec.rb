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
    @guidebook = TravelRoute::Mapper::GuidebookMapper.new(GMAP_TOKEN).generate_guidebook(@attractions)

    @correct_order = [@nthu, @zoo, @taipei_main]
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should be able to generate a correct plan' do
    plan = TravelRoute::Entity::Plan.new(@guidebook).generate_plan(@nthu)
    _(plan.attractions).must_equal(@correct_order)
  end
end
