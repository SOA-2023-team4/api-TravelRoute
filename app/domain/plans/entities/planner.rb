# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class Planner
      def initialize(guidebook)
        @guidebook = guidebook
      end

      def generate_plan(origin)
        visit_order = VisitOrder.new(@guidebook).visited_from(origin)
        routes_for_attractions = @guidebook.routes_in_order(visit_order)
        Plan.new(visit_order, routes_for_attractions)
      end

      # sort the visit order by the nearest neighbor algorithm
      class VisitOrder
        def initialize(guidebook)
          @guidebook = guidebook
          @visited_order = []
          @unvisited = @guidebook.attractions
        end

        def visited_from(origin)
          @visited_order.append(origin)
          @unvisited.delete(origin)
          next_candidate(@visited_order.last, @unvisited) while @unvisited.count.positive?
          @visited_order
        end

        private

        def next_candidate(origin, attractions)
          next_attraction = @guidebook.nearest(origin, attractions)
          @visited_order.append(next_attraction)
          @unvisited.delete(next_attraction)
        end
      end
    end
  end
end
