# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'attraction'
require_relative '../values/duration'
require_relative '../values/distance'

module TravelRoute
  module Entity
    # Data structure for route information
    class TourGuide < Dry::Struct
      include Dry.Types

      attribute :attractions, Strict::Array.of(Attraction)

      def recommend_attractions(top_n = 3)
        attractions.sort_by(&:rating).reverse[0..top_n]
      end
    end
  end
end
