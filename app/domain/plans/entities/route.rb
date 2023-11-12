# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'attraction'
require_relative '../values/duration'
require_relative '../values/distance'

module TravelRoute
  module Entity
    # Data structure for route information
    class Route < Dry::Struct
      include Dry.Types

      attribute :origin,          Attraction
      attribute :destination,     Attraction
      attribute :distance_meters, Strict::Integer
      attribute :duration,        Strict::Integer

      def to_attr_hash
        to_hash.except(:origin, :destination)
      end

      def journey_time
        TravelRoute::Value::Duration.new(duration).estimate_time.join
      end

      def distance
        TravelRoute::Value::Distance.new(distance_meters).estimate_distance.join
      end
    end
  end
end
