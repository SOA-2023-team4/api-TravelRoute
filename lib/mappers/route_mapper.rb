# frozen_string_literal: true

module TravelRoute
  # Data Mapper: Google Maps Route -> Route entity
  class RouteMapper
    def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
      @key = api_key
      @gateway_class = gateway_class
      @gateway = @gateway_class.new(@key)
    end

    def calculate_route(origin, destination)
      data = @gateway.route_data(origin.id, destination.id)
      DataMapper.new(data, origin, destination).build_entity
    end

    # extract entity specific data
    class DataMapper
      attr_reader :origin, :destination

      def initialize(data, origin, destination)
        @data = data
        @origin = origin
        @destination = destination
      end

      def build_entity
        Entity::Route.new(
          origin:,
          destination:,
          distance_meters:,
          duration:
        )
      end

      def distance_meters
        @data['routes'].first['distanceMeters'].to_i
      end

      def duration
        @data['routes'].first['duration'].scan(/\d+/).first.to_i
      end
    end
  end
end
