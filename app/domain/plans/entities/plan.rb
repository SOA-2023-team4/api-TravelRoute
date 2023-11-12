# frozen_string_literal: true

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Plan
      attr_reader :attractions, :routes

      def initialize(attractions, routes)
        @attractions = attractions
        @routes = routes
        # TODO: check if attractions.count - 1 == routes.count
      end

      def self.create_plan_from(origin, guidebook)
        Planner.new(guidebook).generate_plan(origin)
      end

      # Find the route with backtracking travel salesman problem
      class Planner
        INFINITY_COST = Float::INFINITY

        def initialize(guidebook)
          @guidebook = guidebook
          @places = @guidebook.attractions
          @graph = @guidebook.to_matrix
        end

        def generate_plan(origin)
          sorted_places = sort_places(origin)
          route = find_route(sorted_places)
          Plan.new(sorted_places, route)
        end

        def sort_places(origin)
          current = index_of(origin)
          visited = [current]
          (@places.size - 1).times do
            next_place = AttractionFinder.new(@graph[current]).find_next_attraction_from(visited)
            current = next_place
            visited << current
          end
          visited.map { |index| place_at(index) }
        end

        def find_route(sorted_places)
          sorted_places.each_cons(2).map do |origin, destination|
            origin_index = index_of(origin)
            destination_index = index_of(destination)
            @guidebook.matrix[origin_index][destination_index]
          end
        end

        # Find next attraction from origin
        class AttractionFinder
          def initialize(row)
            @row = row
          end

          def find_next_attraction_from(visited)
            visited.each { |index| @row[index] = INFINITY_COST }
            @row.index(@row.min)
          end
        end

        private

        def index_of(place)
          @places.index(place)
        end

        def place_at(index)
          @places[index]
        end
      end
    end
  end
end
