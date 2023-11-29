# frozen_string_literal: true

require 'dry/monads'
require 'json'

module TravelRoute
  module Request
    # Request object for attraction
    class Attraction
      include Dry::Monads::Result::Mixin

      def initialize(body)
        @body = body
      end

      def call
        Success(JSON.parse(@body, symbolize_names: true))
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Cannot parse request body'
          )
        )
      end

      # only for use in tests
      def self.to_request(attraction_hash)
        Attraction.new(attraction_hash.to_json)
      end
    end
  end
end
