# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'place'

module TravelRoute
  module Entity
    # Data structure for route information
    class Waypoint < Dry::Struct
      include Dry.Types

      attribute :waypoints, Array.of(Route)

      def nearest_from(place, except = [])
        exclude = except.empty? ? [place] : except
        possible_places_from(place, exclude).min_by(&:distance_meters)
      end

      def travel_plan_from(place, except = [])
        (possible_routes_from(place).size - 1).times.map do
          except << place
          route = nearest_from(place, except)
          place = route.destination
          route
        end
      end

      def possible_routes_from(place)
        waypoints.select { |point| point.origin == place }
      end

      private

      def filter(place)
        waypoints.select { |point| point.origin == place }
      end

      def possible_places_from(place, except = [])
        filter(place).reject { |point| except.include?(point.destination) }
      end
    end
  end
end
