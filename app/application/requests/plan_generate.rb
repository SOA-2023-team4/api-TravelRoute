# frozen_string_literal: true

require 'dry/monads'
require 'json'

module TravelRoute
  module Request
    # Request for search attraction
    class PlanGenerate
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      def call
        Success({
                  origin_index: @params['origin'].to_i,
                  place_ids: unroll,
                  start_date: @params['start_date'],
                  end_date: @params['end_date']
                })
      rescue StandardError
        Failure(Response::ApiResult.new(status: :bad_request, message: 'Invalid request params'))
      end

      def unroll
        unescape.split(',')
      end

      def unescape
        CGI.unescape(@params['attractions'])
      end

      # for use in tests
      def self.roll(attractions)
        CGI.escape(attractions.join(','))
      end

      def self.to_request(origin_index, attractions, start_date, end_date)
        PlanGenerate.new(
          'origin'      => origin_index,
          'attractions' => roll(attractions),
          'start_date'  => start_date,
          'end_date'    => end_date
          )
      end
    end
  end
end
