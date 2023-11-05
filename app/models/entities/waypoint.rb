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
      attribute :places, Array.of(Place)

      def nearest_destination_from(origin, except = [])
        possible_destination_from(origin, except).min_by(&:distance_meters)
      end

      def travel_plan_from(origin)
        exclude = []
        (places.size - 1).times.map do |_|
          nearest = nearest_destination_from(origin, exclude << origin)
          origin = nearest.destination
          nearest
        end
      end

      def possible_destination_from(origin, except = [])
        exclude = except.empty? ? [origin] : except
        filter(origin).reject { |point| exclude.include?(point.destination) }
      end

      private

      def filter(origin)
        waypoints.select { |point| point.origin == origin }
      end
    end
  end
end
