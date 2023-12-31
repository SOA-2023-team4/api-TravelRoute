# frozen_string_literal: true

module TravelRoute
  module Mixins
    module AttractionDistance
      # Calculate distance between two attractions
      class Connection
        def initialize(from, to)
          @from = from
          @to = to
        end

        def from_lat
          @from.location[:latitude]
        end

        def from_long
          @from.location[:longitude]
        end

        def to_lat
          @to.location[:latitude]
        end

        def to_long
          @to.location[:longitude]
        end

        def distance
          Math.sqrt(((from_lat - to_lat)**2) + ((from_long - to_long)**2))
        end
      end
    end
  end
end
