# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class Planner
      def initialize(guidebook)
        @guidebook = guidebook
      end

      def generate_plan(origin)
        unvisited = @guidebook.attractions
        unvisited.delete(origin)
        visit_order = [origin]
        while unvisited.count.positive?
          next_attraction = @guidebook.nearest(visit_order.last, unvisited)
          visit_order.append(next_attraction)
          unvisited.delete(next_attraction)
        end
        routes_for_attractions = @guidebook.routes_in_order(visit_order)
        Plan.new(visit_order, routes_for_attractions)
      end
    end
  end
end
