# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class DistanceCalculator
      attr_reader :attractions, :matrix

      # Need to do validation
      def initialize(attractions, matrix)
        @attractions = attractions
        @matrix = matrix
        return unless @matrix.size != @attractions.size || @matrix.empty? || @matrix[0].size != @attractions.size

        raise StandardError, 'Matrix size does not match'
      end

      def calculate(from_attraction, to_attraction)
        from_index = @attractions.index(from_attraction)
        to_index = @attractions.index(to_attraction)
        @matrix[from_index][to_index]
      end
    end
  end
end
