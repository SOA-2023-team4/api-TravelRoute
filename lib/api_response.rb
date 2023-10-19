# frozen_string_literal: true

module TravelRoute
  # Data structure for response from api
  class ApiResponse
    module Errors
      # Error for place not found
      class PlaceNotFound < StandardError; end

      # Error for route not found
      class RouteNotFound < StandardError; end

      # Error for unauthorized request
      class Unauthorized < StandardError; end

      # Error for request denied
      class RequestDenied < StandardError; end
    end

    RETURN_STATUS = {
      'REQUEST_DENIED' => Errors::RequestDenied
    }.freeze

    HTTP_ERROR = {
      400 => Errors::Unauthorized
    }.freeze

    def initialize(response)
      @response = response
      @body = response.parse
    end

    def status_code
      @response.code
    end

    def status_message
      @body['status']
    end

    def ok?
      !HTTP_ERROR.keys.include?(status_code)
    end

    def successful?
      !RETURN_STATUS.keys.include?(status_message)
    end

    def body
      raise HTTP_ERROR[status_code] unless ok?
      # raise RETURN_STATUS[status_message] unless successful?

      @body
    end
  end
end
