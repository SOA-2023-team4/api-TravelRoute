# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'attraction'
require_relative '../lib/attraction_distance'
require_relative '../lib/score'

module TravelRoute
  module Entity
    # Data structure for route information
    class TourGuide
      include Mixins::AttractionDistance
      include Mixins::Score

      DISTANCE_WEIGHT = 0.4
      RATING_WEIGHT = 0.6

      def initialize(attraction_web)
        @attraction_web_list = Value::AttractionList.new(attraction_web[:attractions])
      end

      def attractions = @attraction_web_list.attractions

      def recommend_attractions(top_n = 3)
        target_attractions = high_rating_attractions
        scores = calculate_scores(target_attractions)
        target_attractions.zip(scores).sort_by { |_, score| score }.reverse[0..(top_n - 1)].map(&:first)
      end

      private

      def calculate_scores(target_attractions)
        distances = Normalizer.new(attraction_distance_to_hubs(target_attractions)).normalize
        ratings = Normalizer.new(target_attractions.map(&:rating)).normalize
        distances.zip(ratings).map { |dis, rat| (dis * DISTANCE_WEIGHT) + (rat * RATING_WEIGHT) }
      end

      def attraction_distance_to_hubs(target_attractions)
        hubs = attractions.map(&:hub)
        target_attractions.map do |point|
          hubs.map do |hub|
            Connection.new(point, hub).distance
          end.min
        end
      end

      def high_rating_attractions(threshold = 4.0)
        unique_attractions.select { |attraction| attraction.rating >= threshold }
      end

      def unique_attractions
        attractions.map(&:nodes).flatten.uniq
      end
    end
  end
end
