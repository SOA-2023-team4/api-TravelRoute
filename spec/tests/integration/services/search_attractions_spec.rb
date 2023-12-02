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

  describe 'Search Attraction' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should get the candidate attractions' do
      correct = TravelRoute::Mapper::AttractionMapper.new(GMAP_TOKEN).find('nthu').first
      search = TravelRoute::Request::AttractionSearch.to_request('清大')
      result = TravelRoute::Service::SearchAttractions.new.call(search)

      _(result.success?).must_equal true
      candidates = result.value!.message
      _(candidates.count).must_equal 1
      _(candidates['attractions'].first).must_equal correct
    end

    it 'SAD: should report if no attractions are found' do
      search = TravelRoute::Request::AttractionSearch.to_request('invaliddestinationId')
      result = TravelRoute::Service::SearchAttractions.new.call(search)

      _(result.success?).must_equal true
      candidates = result.value!.message
      _(candidates['attractions']).must_be_empty
    end
  end
end
