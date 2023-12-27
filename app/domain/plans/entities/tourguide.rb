# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'attraction'
require_relative '../lib/attraction_distance'

module TravelRoute
  # Value object to normalize data
  class NumericScores
    def initialize(nums)
      @nums = nums
    end

    def normalize(nums)
      mean = nums.sum / nums.size
      std = Math.sqrt(nums.map { |num| (num - mean)**2 }.sum / nums.size)
      nums.map { |num| (num - mean) / std }
    end
  end

  # Value object about attractions associated with a given attraction
  class AssociatedAttractions
    def initialize(attraction_webs)
      @assocations = attraction_webs
    end

    def ratings
      @assocations.map(&:rating)
    end

    def unique_attractions
      @assocations.map(&:nodes).flatten.uniq
    end
  end

  module Entity
    # Data structure for route information
    class TourGuide# < Dry::Struct
      # include Dry.Types
      include Mixins::AttractionDistance

      # attribute :attractions, Strict::Array.of(AttractionWeb)

      DISTANCE_WEIGHT = 0.4
      RATING_WEIGHT = 0.6

      def initialize(attractions)
        @attractions = attractions
      end

      def recommend_attractions(top_n = 3)
        target_attractions = high_rating_attractions
        scores = calculate_scores(target_attractions)
        target_attractions.zip(scores).sort_by { |_, score| score }.reverse[0..(top_n - 1)].map(&:first)
      end

      private

      def calculate_scores(target_attractions)
        distances = NumericScores.new(attraction_distance_to_hubs(target_attractions)).normalize
        ratings = NumericScores.new(target_attractions.map(&:rating)).normalize
        distances.zip(ratings).map { |d, r| (d * DISTANCE_WEIGHT) + (r * RATING_WEIGHT) }
      end

      # def normalize(nums)
      #   mean = nums.sum / nums.size
      #   std = Math.sqrt(nums.map { |num| (num - mean)**2 }.sum / nums.size)
      #   nums.map { |num| (num - mean) / std }
      # end

      def attraction_distance_to_hubs(target_attractions)
        hubs = @attractions.map(&:hub)
        target_attractions.map do |a|
          hubs.map do |hub|
            calculate_distance(a, hub)
          end.min
        end
      end

      def high_rating_attractions(threshold = 4.0)
        unique_attractions.select { |attraction| attraction.rating >= threshold }
      end

      def unique_attractions
        @attractions.map(&:nodes).flatten.uniq
      end
    end
  end
end
