# frozen_string_literal: true

module TravelRoute
  module Entity
    # Data structure for route information
    class AttractionSet
      def initialize(attractions = [])
        @attractions = attractions
        @attraction_ids = Set.new(attractions.map(&:place_id))
      end

      def add(attraction)
        return if @attraction_ids.include?(attraction.place_id)

        @attractions.append(attraction)
        @attraction_ids.add(attraction.place_id)
      end

      def delete(attraction)
        @attractions.delete(attraction)
        @attraction_ids.delete(attraction.place_id)
      end

      def contains(attraction)
        @attraction_ids.include?(attraction.place_id)
      end
    end
  end
end
