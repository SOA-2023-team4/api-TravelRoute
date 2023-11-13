# frozen_string_literal: true

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Plan
      attr_reader :attractions, :routes

      def initialize(attractions, routes)
        @attractions = attractions
        @routes = routes
        # TODO: check if attractions.count - 1 == routes.count
      end

      def starting_point
        @attractions.first
      end

      def longest_route
        @routes.max_by(&:distance_meters)
      end
    end
  end
end
