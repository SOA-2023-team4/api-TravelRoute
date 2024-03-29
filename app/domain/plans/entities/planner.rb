# frozen_string_literal: true

module TravelRoute
  module Entity
    # responsible for running the algorithm to generate plans
    class Planner
      def initialize(attractions, distance_calculator)
        @attractions = attractions
        @distance_calculator = distance_calculator
      end

      # TODO: implement min distance
      def generate_plan(day_durations, start_date_str, end_date_str)
        plans = generate_plans(day_durations, start_date_str, end_date_str)
        return nil if plans.empty?

        plans.sort_by!(&:travel_distance)
        plans[0]
      end

      def generate_plans(day_durations, start_date_str, end_date_str)
        result = []
        current_plan = Plan.new(@distance_calculator, day_durations, start_date_str, end_date_str)
        visited = AttractionSet.new
        days = day_durations.size
        backtrack(current_plan, 0, 0, days, result, visited)
        result
      end

      def backtrack(current_plan, day, attraction_count, days, result, visited)
        return result.append(Marshal.load(Marshal.dump(current_plan))) if attraction_count == @attractions.size
        return if day >= days

        @attractions.each do |attraction|
          next if visited.contains(attraction)
          next unless current_plan.can_append_attraction(day, attraction)

          current_plan.append_attraction(day, attraction)
          visited.add(attraction)

          backtrack(current_plan, day, attraction_count + 1, days, result, visited)

          current_plan.pop_attraction(day)
          visited.delete(attraction)
        end
        backtrack(current_plan, day + 1, attraction_count, days, result, visited)
      end
    end
  end
end
