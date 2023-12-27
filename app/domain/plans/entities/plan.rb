# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class Plan
      # ReturnObject = Struct.new(:attractions, :routes)

      attr_reader :attractions, :routes

      def initialize(guidebook, origin)
        @guidebook = guidebook
        @origin = origin
      end

      def attractions = @attractions ||= VisitOrder.new(@guidebook).visited_from(origin)

      def routes = @routes ||= @guidebook.routes_in_order(visit_order)

      # def generate_plan
      #   visit_order = VisitOrder.new(@guidebook).visited_from(origin)
      #   routes_for_attractions = @guidebook.routes_in_order(visit_order)
      #   # ReturnObject.new(attractions: visit_order, routes: routes_for_attractions)
      #   @attractions = visit_order
      #   @routes = routes_for_attractions
      # end

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
