# frozen_string_literal: true

module TravelRoute
  # Data Mapper: Google Maps Route -> Waypoint entity
  class GuidebookMapper
    def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
      @key = api_key
      @gateway_class = gateway_class
      @gateway = @gateway_class.new(@key)
    end

    def construct_from(places)
      data = @gateway.route_matrix_data(places)
      DataMapper.new(data, places).build_entity
    end

    # extract entity specific data
    class DataMapper
      def initialize(data, places)
        @data = data
        @places = places
      end

      def build_entity
        place_count = @places.count
        matrix = Array.new(place_count) { Array.new(place_count) }
        @data.each do |entry|
          origin_index = entry['originIndex']
          destination_index = entry['destinationIndex']
          origin = place_at(origin_index)
          destination = place_at(destination_index)
          matrix[origin_index][destination_index] = RouteMapper::DataMapper.new(entry, origin, destination).build_entity
        end
        Entity::Guidebook.new(@places, matrix)
      end

      private

      def place_at(index)
        @places[index]
      end
    end
  end
end
