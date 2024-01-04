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

      def before_save
        self.opening_hours = opening_hours&.to_json
        super
      end

      def location
        { latitude:, longitude: }
      end

      def location=(location)
        self.latitude = location[:latitude]
        self.longitude = location[:longitude]
      end

      def opening_hours
        super.is_a?(String) ? JSON.parse(super, symbolize_names: true) : super
      end

      def to_hash
        super[:opening_hours] = opening_hours
        super[:location] = location
        super.delete(:latitude)
        super.delete(:longitude)
        super
      end
    end
  end
end
