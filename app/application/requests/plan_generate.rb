# frozen_string_literal: true

require 'dry/monads'
require 'json'

module TravelRoute
  module Request
    # Request for search attraction
    class PlanGenerate
      include Dry::Monads::Result::Mixin

      PlanGenerateRequest = Struct.new(:origin_index, :place_ids)

      def initialize(params)
        @params = params
      end

      def call
        Success(PlanGenerateRequest.new(@params['origin_index'].to_i, unroll(@params['attractions'])))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :bad_request, message: 'Invalid request params'))
      end

      def unroll(attractions)
        unescape(attractions).split(',')
      end

      def unescape(param)
        CGI.unescape(param)
      end

      # for use in tests
      def self.roll(attractions)
        CGI.escape(attractions.join(','))
      end

      def self.to_request(origin_index, attractions)
        PlanGenerate.new('origin_index' => origin_index, 'attractions' => roll(attractions))
      end
    end
  end
end
