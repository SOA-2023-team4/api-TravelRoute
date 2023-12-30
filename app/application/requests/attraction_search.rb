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
        # Success(unescape(@params['search']))
        Success(unescape)
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Invalid request params'
          )
        )
      end

      def unescape
        CGI.unescape(@params['search'])
      end

      # for use in tests
      def self.to_escape(search_term)
        CGI.escape(search_term)
      end

      def self.to_request(search_term)
        AttractionSearch.new('search' => to_escape(search_term))
      end
    end
  end
end
