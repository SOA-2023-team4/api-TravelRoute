# frozen_string_literal: true

module TravelRoute
  module Mixins
    module Score
      # Normalize data
      class Normalizer
        def initialize(nums)
          @nums = nums
        end

        def size
          @nums.size
        end

        def mean
          @nums.sum / size
        end

        def std
          Math.sqrt(@nums.map { |num| (num - mean)**2 }.sum / size)
        end

        def normalize
          @nums.map { |num| (num - mean) / std }
        end
      end
    end
  end
end
