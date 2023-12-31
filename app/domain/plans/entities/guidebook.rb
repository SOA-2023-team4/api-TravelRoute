# frozen_string_literal: true

require_relative '../values/distance'
require_relative '../values/attraction_list'

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Guidebook
      def initialize(attractions, matrix)
        @attraction_list = Value::AttractionList.new(attractions)
        @matrix = matrix
      end

      def attractions = @attraction_list.attractions

      def distance_matrix
        @matrix.map do |row|
          row.map(&:distance_meters)
        end
      end

      # Returns the nearest attraction in attractions originating from origin
      def nearest(origin, attractions)
        raise 'origin not in guidebook' unless @attraction_list.has?(origin)
        raise 'one or more attraction(s) not in guidebook' unless @attraction_list.all?(attractions)

        attractions.min_by do |attraction|
          route(origin, attraction).distance_meters
        end
      end

      # Returns a Sequential route list that matches the places given
      def routes_in_order(attractions)
        raise 'one or more attraction(s) not in guidebook' unless @attraction_list.all?(attractions)

        attractions.each_cons(2).map do |from, to|
          route(from, to)
        end
      end

      private

      def route(from_attraction, to_attraction)
        from_index = @attraction_list.index_of(from_attraction)
        to_index = @attraction_list.index_of(to_attraction)
        @matrix[from_index][to_index]
      end
    end
  end
end
