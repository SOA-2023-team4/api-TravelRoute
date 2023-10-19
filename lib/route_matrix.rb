# frozen_string_literal: true

module TravelRoute
  # Data structure for Route Matrix
  class RouteMatrix
    def initialize(matrix_data, places)
      @matrix_data = matrix_data
      @places = places
    end

    def nearest_from(place, except = [])
      nearest = possible_routes(place, except).min_by { |m| m['duration'].delete('s').to_i }
      destination = places_at(nearest['destinationIndex'])
      route_data = nearest.merge('origin' => place, 'destination' => destination)
      Route.new(route_data)
    end

    def construct_route_from(origin)
      route = []
      except = []
      (@places.size - 1).times do
        route << nearest_from(origin, except)
        except << origin
        origin = route.last.destination
      end
      route
    end

    private

    def index_of(place)
      @places.index(place)
    end

    def places_at(index)
      @places[index]
    end

    def possible_routes(origin, except = [])
      except_index = ([origin] + except).map { |exp| index_of(exp) }
      @matrix_data.select do |m|
        m['originIndex'] == except_index.first && !except_index.include?(m['destinationIndex'])
      end
    end
  end
end
