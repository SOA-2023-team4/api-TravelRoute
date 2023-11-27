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

    it 'HAPPY: should get the candidate attractions' do
      correct = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('nthu').first
      search_term = '清大'
      result = TravelRoute::Service::SearchAttractions.new.call(search_term)

      _(result.success?).must_equal true
      candidates = result.value!
      _(candidates.length).must_equal 1
      _(candidates.first).must_equal correct
    end

    it 'SAD: should report if no attractions are found' do
      search_term = 'invaliddestinationId'
      result = TravelRoute::Service::SearchAttractions.new.call(search_term)

      _(result.success?).must_equal true
      candidates = result.value!
      _(candidates).must_be_empty
    end
  end
end
