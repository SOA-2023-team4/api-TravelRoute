# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/distance'

module TravelRoute
  module Entity
    # Data structure for place information
    class Attraction < Dry::Struct
      include Dry.Types

      attribute :place_id,        Strict::String
      attribute :name,            Strict::String
      attribute :address,         Strict::String
      attribute? :type,           Strict::String.optional
      attribute? :opening_hours,  Strict::Hash.optional
      attribute :rating,          Coercible::Float.optional
      attribute :location,        Hash.optional

      def to_attr_hash
        {
          place_id:,
          name:,
          address:,
          type:,
          opening_hours:,
          rating:,
          latitude: location[:latitude],
          longitude: location[:longitude]
        }
      end

      def country
        address.split(',').last.strip
      end

      def city
        address.split(',')[-2].strip
      end
    end
  end
end
