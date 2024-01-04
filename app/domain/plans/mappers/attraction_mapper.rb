# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Attraction -> Attraction entity
    class AttractionMapper
      def initialize(api_key, gateway_class = GoogleMaps::Places::Api)
        @key = api_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def find(place_name)
        data = @gateway.places_from_text_data(place_name)['places']
        return [] unless data

        data.map { |entry| DataMapper.new(entry).build_entity }
      end

      def find_by_id(place_id)
        entry = @gateway.place_detail_data(place_id)
        DataMapper.new(entry).build_entity
      end

      def places_nearby(longitude, latitude, type = 'attraction')
        data = @gateway.places_nearby(longitude, latitude, type)['places']
        data.map { |entry| DataMapper.new(entry).build_entity }
      end

      private

      def get_place_detail(data)
        candidates = data['candidates']
        place_ids = candidates.map { |entry| entry['place_id'] }
        place_ids.map { |place_id| @gateway.place_detail_data(place_id)['result'] }
      end

      # extract entity specific data
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Attraction.new(
            place_id:,
            name:,
            address:,
            rating:,
            type:,
            opening_hours:,
            location:
          )
        end

        private

        def place_id
          @data['id']
        end

        def address
          @data['formattedAddress']
        end

        def name
          @data['displayName']['text']
        end

        def rating
          @data['rating']
        end

        def opening_hours
          OpeningHoursDataMapper.new(@data['regularOpeningHours']).build_entity
        end

        def type
          @data['primaryType']
        end

        def location
          @data['location'].transform_keys(&:to_sym)
        end
      end

      # class for mapping opening hours
      class OpeningHoursDataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          default_hours = Value::OpeningHours.new(
            opening_hours: Array.new(
              7,
              Value::OpeningHour.new(
                day_start: Value::Time.new(hour: 0, minute: 0),
                day_end: Value::Time.new(hour: 23, minute: 59)
              )
            )
          )
          return default_hours unless @data
          @data['periods'].map do |entry|
            Value::OpeningHour.new(
              day_start: Value::Time.new(hour: entry['open']['hour'], minute: entry['open']['minute']),
              day_end: Value::Time.new(hour: entry['close']['hour'], minute: entry['close']['minute'])
            )
          end
        end
      end
    end
  end
end
