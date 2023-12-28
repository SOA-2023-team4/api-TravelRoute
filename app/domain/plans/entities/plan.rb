# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class Plan
      def initialize(guidebook, origin)
        @guidebook = guidebook
        @origin = origin
      end

      def attractions
        @attractions ||= VisitOrder.new(@guidebook).visited_from(@origin)
      end

      def routes
        @routes ||= @guidebook.routes_in_order(attractions)
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
