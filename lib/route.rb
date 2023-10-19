# frozen_string_literal: true

module TravelRoute
  # Data structure for place information
  class Route
    def initialize(route_data)
      @route = route_data
    end

    def origin
      @route['origin']
    end

    def destination
      @route['destination']
    end

    def distance_meters
      @route['distanceMeters']
    end

    def duration
      @route['duration']
    end

    # def polyline
    #   @route['polyline']['encodedPolyline'] || nil
    # end
  end
end
