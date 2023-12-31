# frozen_string_literal: true

module TravelRoute
  module Value
    # Value object for indexing operations on attractions
    class AttractionList
      def initialize(attractions)
        @list = attractions
        @index = attractions.each_with_index.to_h
      end

      def attractions = @list

      def has?(attraction)
        @index.key?(attraction)
      end

      def all?(attractions)
        attractions.all? { |attraction| has?(attraction) }
      end

      def index_of(attraction)
        raise "#{attraction} not in guidebook" unless has?(attraction)

        @index[attraction]
      end

      def indexes_of(attractions)
        attractions.map { |attraction| index_of(attraction) }
      end

      def attraction_of(index)
        raise 'index out of range' if index >= @list.count || index.negative?

        @index[index]
      end
    end
  end
end
