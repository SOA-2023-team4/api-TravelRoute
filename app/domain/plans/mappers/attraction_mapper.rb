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

        def self.default_entity
          Value::OpeningHours.new(
            opening_hours: Array.new(
              7,
              Value::OpeningHour.new(
                day_start: Value::Time.new(hour: 7, minute: 0),
                day_end: Value::Time.new(hour: 23, minute: 0)
              )
            )
          )
        end

        def build_entity
          return OpeningHoursDataMapper.default_entity unless @data

          Value::OpeningHours.new(opening_hours:)
        end

        private

        def opening_hours(list = Array.new(7, Value::OpeningHour::NOT_OPEN))
          @data['periods'].map do |entry|
            open_day = entry['open']['day']
            # close_day = entry['close']['day']
            # raise Exception, 'Open day not same as close day' unless open_day == close_day

            opening_hour = Value::OpeningHour.new(
              day_start: day_start(entry),
              day_end: day_end(entry)
            )
            list[open_day] = opening_hour
          end
        end

        def day_start(entry)
          open = entry['open']
          return Value::Time.new(hour: 7, minute: 0) unless open

          Value::Time.new(hour: open['hour'], minute: open['minute'])
        end

        def day_end(entry)
          close = entry['close']

          return Value::Time.new(hour: 23, minute: 0) unless close

          Value::Time.new(hour: close['hour'], minute: close['minute'])
        end
      end
    end
  end
end
