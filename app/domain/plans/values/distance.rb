# frozen_string_literal: true

require_relative '../lib/distance_estimator'

module TravelRoute
  module Value
    # Value of route's distance
    class Distance
      include Mixins::DistanceEstimator

      def initialize(distance)
        @distance = distance
      end
    end
  end
end
