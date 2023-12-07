# frozen_string_literal: true

require_relative '../lib/duration_estimator'

module TravelRoute
  module Value
    # Value of route's duration
    class Duration
      include Mixins::DurationEstimator

      def initialize(duration)
        @duration = duration
      end
    end
  end
end
