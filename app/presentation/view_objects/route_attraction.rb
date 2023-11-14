# frozen_string_literal: true

module Views
  # View object for plan
  class RouteAttraction
    def initialize(route, attraction)
      @route = route
      @attraction = attraction
    end

    def distance
      @route.distance
    end

    def duration
      @route.duration
    end

    def name
      @attraction.name
    end

    def address
      @attraction.address
    end

    def rating
      @attraction.rating
    end
  end
end
