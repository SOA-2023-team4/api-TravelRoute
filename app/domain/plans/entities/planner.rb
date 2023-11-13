# frozen_string_literal: true

module TravelRoute
  module Entity
    # Find the route with backtracking travel salesman problem
    class Planner
      INFINITY_COST = Float::INFINITY

      def initialize(guidebook)
        @guidebook = guidebook
        @places = @guidebook.attractions
        @graph = @guidebook.to_matrix
      end

      def generate_plan(origin)
        places = @places
        places.delete(origin)
        places.insert(0, origin)
        routes = find_routes(places)
        Plan.new(places, routes)
      end

      def find_routes(places)
        places.each_cons(2).map do |origin, destination|
          origin_index = index_of(origin)
          destination_index = index_of(destination)
          @guidebook.matrix[origin_index][destination_index]
        end
      end
    end
  end
end
