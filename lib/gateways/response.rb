# frozen_string_literal: true

module TravelRoute
  # Decorates HTTP responses with sucess/error
  class Response < SimpleDelegator
    Unauthorized = Class.new(StandardError)
    NotFound = Class.new(StandardError)
    BadRequest = Class.new(StandardError)

    HTTP_ERROR = {
      400 => BadRequest,
      401 => Unauthorized,
      404 => NotFound
    }.freeze

    STATUS_ERROR = {
      'REQUEST_DENIED' => Unauthorized
    }.freeze

    def successful?
      HTTP_ERROR.keys.none?(code) && STATUS_ERROR.keys.none?(parse['status'])
    end

    def error
      HTTP_ERROR.keys.none?(code) ? STATUS_ERROR[parse['status']] : HTTP_ERROR[code]
    end
  end
end
