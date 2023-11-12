# frozen_string_literal: true

module TravelRoute
  module Value
    # Value of route's duration
    class Duration
      def initialize(duration)
        @duration = duration
      end

      def to_sec
        [@duration, 's']
      end

      def to_min
        [(@duration / 60).ceil, 'min']
      end

      def to_hour
        [(@duration / 3600).ceil, 'h']
      end

      def estimate_time
        case @duration
        when @duration < 60
          to_sec
        when @duration >= 60 && @duration < 3600
          to_min
        when @duration >= 3600
          to_hour
        end
      end
    end
  end
end
