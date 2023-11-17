# frozen_string_literal: true

require_relative '../values/distance'

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Guidebook
      attr_reader :attractions

      def initialize(attractions, matrix)
        @attractions = attractions
        @attraction_to_index = {}
        @attractions.each_with_index do |attraction, ind|
          @attraction_to_index[attraction] = ind
        end
        @matrix = matrix
      end

      def distance_matrix
        @matrix.map do |row|
          row.map(&:distance_meters)
        end
      end

      def index_of(attraction)
        raise "#{attraction} not in guidebook" unless @attraction_to_index.key?(attraction)

        @attraction_to_index[attraction]
      end

      def indexes_of(attractions)
        attractions.map { |attraction| index_of(attraction) }
      end

      def attraction_of(index)
        raise 'index out of range' if index >= @attractions.count || index.negative?

        @attractions[index]
      end

      def route(from_attraction, to_attraction)
        from_index = index_of(from_attraction)
        to_index = index_of(to_attraction)
        @matrix[from_index][to_index]
      end

      def has?(attraction)
        @attraction_to_index.key?(attraction)
      end

      def all?(attractions)
        attractions.all? { |attraction| has?(attraction) }
      end

      # Returns the nearest attraction in attractions originating from origin
      def nearest(origin, attractions)
        raise 'origin not in guidebook' unless has?(origin)
        raise 'one or more attraction(s) not in guidebook' unless all?(attractions)

        attractions.min_by do |attraction|
          route(origin, attraction).distance_meters
        end
      end

      # Returns a Sequential route list that matches the places given
      def routes_in_order(attractions)
        raise 'one or more attraction(s) not in guidebook' unless all?(attractions)

        attractions.each_cons(2).map do |from, to|
          route(from, to)
        end
      end
    end
  end
end
