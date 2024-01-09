# frozen_string_literal: true

module TravelRoute
  module Entity
    # the class for holding continguous days (across weeks) opening hours
    class VisitDuration
      attr_reader :start, :attraction, :end

      def initialize(start, attraction)
        @start = start
        @attraction = attraction
        @end = start + @attraction.stay_time
      end
    end
  end
end
