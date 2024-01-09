# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Route -> Waypoint entity
    class DistanceCalculatorMapper
      def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
        @key = api_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def distance_calculator_for(attractions)
        data = @gateway.route_matrix_data(attractions)
        matrix = Array.new(attractions.length) { Array.new(attractions.length) }
        data.each do |entry|
          duration = TravelRoute::Value::Time.from_str(entry['duration'])
          matrix[entry['originIndex']][entry['destinationIndex']] = duration
        end
        TravelRoute::Entity::DistanceCalculator.new(attractions, matrix)
      end
    end
  end
end
