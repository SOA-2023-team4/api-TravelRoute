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
        Success(PlanGenerateRequest.new(@params['origin'].to_i, unroll))
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

      def self.to_request(origin_index, attractions)
        PlanGenerate.new('origin' => origin_index, 'attractions' => roll(attractions))
      end
    end
  end
end
