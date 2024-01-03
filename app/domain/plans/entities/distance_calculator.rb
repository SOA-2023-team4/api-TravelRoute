# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class DistanceCalculator
      # Need to do validation
      def initialize(attractions, matrix)
        @attractions = attractions # List[Attraction]
        @matrix = matrix # List[List[Time]]
      end

      def calculate(from_attraction, to_attraction)
        from_index = @attractions.index(from_attraction)
        to_index = @attractions.index(to_attraction)
        @matrix[from_index][to_index]
      end
    end
  end
end
