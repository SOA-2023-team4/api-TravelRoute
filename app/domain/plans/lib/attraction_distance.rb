# frozen_string_literal: true

module TravelRoute
  module Mixins
    # Calculate distance between two attractions
    module AttractionDistance
      def calculate_distance(from_attraction, to_attraction)
        lat1 = from_attraction.location[:latitude]
        long1 = from_attraction.location[:longitude]
        lat2 = to_attraction.location[:latitude]
        long2 = to_attraction.location[:longitude]
        Math.sqrt(((lat1 - lat2)**2) + ((long1 - long2)**2))
      end

      def normalize(nums)
        mean = nums.sum / nums.size
        std = Math.sqrt(nums.map { |num| (num - mean)**2 }.sum / nums.size)
        nums.map { |num| (num - mean) / std }
      end
    end
  end
end
