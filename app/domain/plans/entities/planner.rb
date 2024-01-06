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
        current_plan = Plan.new(@distance_calculator, day_durations, start_date_str, end_date_str)
        visited = AttractionSet.new
        days = day_durations.size
        backtrack(current_plan, 0, 0, days, attractions, result, visited)
        result
      end

      def backtrack(current_plan, day, attraction_count, days, attractions, result, visited)
        if attraction_count == attractions.size
          result.append(Marshal.load(Marshal.dump(current_plan)))
          return
        end

        return if day >= days
        
        attractions.each do |attraction|
          next if visited.contains(attraction)
          if current_plan.can_append_attraction(day, attraction)
            current_plan.append_attraction(day, attraction)
            visited.add(attraction)

            backtrack(current_plan, day, attraction_count+1, days, attractions, result, visited)

            current_plan.pop_attraction(day)
            visited.delete(attraction)
          end
        end
        backtrack(current_plan, day+1, attraction_count, days, attractions, result, visited)
      end
    end
  end
end
