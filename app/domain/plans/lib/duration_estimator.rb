# frozen_string_literal: true

module TravelRoute
  module Mixins
    # duration estimation methods
    module DurationEstimator
      def to_sec
        [duration, 's']
      end

      def to_min
        [(duration / 60).ceil, 'min']
      end

      def to_hour
        [(duration / 3600).ceil, 'h']
      end

      def estimate_time
        case duration
        when 0..59
          to_sec
        when 59..3599
          to_min
        else
          to_hour
        end
      end
    end
  end
end
