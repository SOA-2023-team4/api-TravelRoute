# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module TravelRoute
  module Request
    # Request for search attraction
    class AttractionSearch
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      def call
        Success(decode(@params['search']))
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Invalid request params'
          )
        )
      end

      def decode(param)
        Base64.urlsafe_decode64(param)
      end
    end
  end
end
