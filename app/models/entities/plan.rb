# frozen_string_literal: true

require_relative 'attraction'

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Plan
      def initialize(attractions, routes)
        @attractions = attractions
        @routes = routes
        # TODO: check if attractions.count - 1 == routes.count
      end
    end
  end
end
