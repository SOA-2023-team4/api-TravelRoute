# frozen_string_literal: true

module TravelRoute
  module Entity
    # responsible for running the algorithm to generate plans
    class Planner
      def initialize(distance_calculator)
        @distance_calculator = distance_calculator
      end

      def generate_plans(attractions, day_durations, start_date_str, end_date_str)
        result = []
      end
    end
  end
end
