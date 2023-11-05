# frozen_string_literal: true

module TravelRoute
  # Data Mapper: Google Maps Route -> Waypoint entity
  class WaypointMapper
    def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
      @key = api_key
      @gateway_class = gateway_class
      @gateway = @gateway_class.new(@key)
    end

    def waypoints(places)
      data = @gateway.route_matrix_data(places)
      DataMapper.new(data, places).build_entity
    rescue NoMethodError
      raise Response::BadRequest
    end

    # extract entity specific data
    class DataMapper
      def initialize(data, places)
        @data = data
        @places = places
      end

      def build_entity
        waypoints = @data.map do |entry|
          origin = place_at(entry['originIndex'])
          destination = place_at(entry['destinationIndex'])
          RouteMapper::DataMapper.new(entry, origin, destination).build_entity
        end
        Entity::Waypoint.new(waypoints:, places: @places)
      end

      private

      def place_at(index)
        @places[index]
      end
    end
  end
end
