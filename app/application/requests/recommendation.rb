# frozen_string_literal: true

require 'dry/monads'
require 'json'

module TravelRoute
  module Request
    # Request object for attraction
    class Recommendation
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      def call
        ids = CGI.unescape(@params['ids']).split(',')
        exclude = @params.keys.include?('exclude') ? CGI.unescape(@params['exclude']).split(',') : nil
        Success(ids:, exclude:)
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Invalid request params'
          )
        )
      end
    end
  end
end
