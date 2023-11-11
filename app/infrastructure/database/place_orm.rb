# frozen_string_literal: true

require 'sequel'

module TravelRoute
  module Database
    # Object-Relational Mapper for Places
    class PlaceOrm < Sequel::Model(:places)
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
    end
  end
end
