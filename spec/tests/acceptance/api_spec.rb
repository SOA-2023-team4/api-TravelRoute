# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'
require 'base64'

def app
  TravelRoute::App
end

describe 'Acceptance testing' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_gmap
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  # describe 'Test root route' do
  #   it 'HAPPY: should successfully return root information' do
  #     get '/'
  #     _(last_response.status).must_equal 200

  #     body = JSON.parse(last_response.body)
  #     _(body['status']).must_equal 'ok'
  #     _(body['message']).must_include 'api/v1'
  #   end
  # end

  # describe 'Attraction route' do
  #   it 'HAPPY: should be able to search for attraction' do
  #     search_term = CGI.escape('清大')
  #     get "/api/v1/attractions?search=#{search_term}"
  #     _(last_response.status).must_equal 200

  #     body = JSON.parse(last_response.body)
  #     assert_operator body['attractions'].count, :>, 0
  #   end

  #   it 'HAPPY: should be able to get attraction by place_id' do
  #     place_id = 'ChIJB7ZNzXI2aDQREwR22ltdKxE'
  #     get "/api/v1/attractions/#{place_id}"
  #     _(last_response.status).must_equal 202

  #     body = JSON.parse(last_response.body)
  #     expected = PLACE_DETAIL_RESULT['nthu']
  #     _(body['place_id']).must_equal expected['id']
  #     _(body['name']).must_equal expected['displayName']['text']
  #     _(body['address']).must_equal expected['formattedAddress']
  #     _(body['rating']).must_equal expected['rating']
  #   end
  # end

  # ChIJlWImqHKpQjQREk5-6lec4-w Taipei Main Station
  # ChIJl78Wnt01aDQRz1shOsBVUGU Hsinchu Zoo
  # ChIJB7ZNzXI2aDQREwR22ltdKxE National Tsing Hua University
  describe 'Plan route' do
    it 'HAPPY: should be able to generate a plan' do
      attractions_list = %w[ChIJlWImqHKpQjQREk5-6lec4-w ChIJl78Wnt01aDQRz1shOsBVUGU ChIJB7ZNzXI2aDQREwR22ltdKxE]
      attractions = CGI.escape(attractions_list.join(','))
      origin = 2
      start_date = '2023-01-10'
      end_date = '2023-01-10'
      get "/api/v1/plans?origin=#{origin}&attractions=#{attractions}&start_date=#{start_date}&end_date=#{end_date}&start_time=09:00&end_time=18:00"
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['day_plans'].count).must_equal 1
      _(body['day_plans'][0]['visit_durations'].count).must_equal 3
      # _(body['attractions'].count).must_equal 3
      # _(body['routes'].count).must_equal 2
    end
  end
end
