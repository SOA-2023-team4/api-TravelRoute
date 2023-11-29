# frozen_string_literal: true

require 'sequel'

module TravelRoute
  module Database
    # Object-Relational Mapper for attraction
    class AttractionOrm < Sequel::Model(:attractions)
      one_to_many :from,
                  class: :'TravelRoute::Database::RouteOrm',
                  key: :origin_id

      many_to_many :to,
                   class: :'TravelRoute::Database::RouteOrm',
                   key: :destination_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(place_info)
        first(name: place_info[:name], place_id: place_info[:place_id]) || create(place_info)
      end

      def opening_hours
        return nil unless opening_hours_json

        JSON.parse(opening_hours_json)
      end

      def opening_hours=(value)
        self.opening_hours_json = value&.to_json
      end

      def to_hash
        {
          id:,
          place_id:,
          name:,
          address:,
          type:,
          rating:,
          opening_hours:
        }
      end
    end
  end
end
