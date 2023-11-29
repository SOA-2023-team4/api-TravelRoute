# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Route -> Route entity
    class RouteMapper
      def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
        @key = api_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def calculate_route(origin, destination)
        data = @gateway.route_data(origin.place_id, destination.place_id)
        DataMapper.new(data, origin, destination).build_entity
      rescue NoMethodError
        raise GoogleMaps::Response::BadRequest
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
          data = @data.keys.include?('routes') ? @data['routes'].first : @data
          data['distanceMeters'].to_i
        end

        def duration
          data = @data.keys.include?('routes') ? @data['routes'].first : @data
          data['duration'].scan(/\d+/).first.to_i
        end
      end
    end
  end
end
