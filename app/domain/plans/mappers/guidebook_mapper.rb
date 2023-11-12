# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Route -> Waypoint entity
    class GuidebookMapper
      def initialize(api_key, gateway_class = GoogleMaps::Routes::Api)
        @key = api_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def generate_guidebook(places)
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
          routes = @data.map do |entry|
            origin = place_at(entry['originIndex'])
            destination = place_at(entry['destinationIndex'])
            RouteMapper::DataMapper.new(entry, origin, destination).build_entity
          end
          Entity::Guidebook.new(@places, RerrangeData.new(@places, routes).to_matrix)
        end

        # Rearrange data into a matrix
        class RerrangeData
          def initialize(places, routes)
            @places = places
            @routes = routes
          end

          def to_matrix
            @places.map do |place|
              rearrange(place)
            end
          end

          private

          def index_of(place)
            @places.index(place)
          end

          def rearrange(place)
            @routes.select { |entry| entry.origin == place }
              .sort_by { |entry| index_of(entry.destination) }
          end
        end

        private

        def place_at(index)
          @places[index]
        end
      end
    end
  end
end
