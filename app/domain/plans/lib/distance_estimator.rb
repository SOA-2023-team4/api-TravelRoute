# frozen_string_literal: true

module TravelRoute
  module Mixins
    # Distance estimation methods
    module DistanceEstimator
      def to_m
        distance
      end

      def to_km
        (to_m / 1000).ceil
      end

      def estimate_distance
        distance < 1000 ? [to_m, 'm'] : [to_km, 'km']
      end
    end
  end
end
