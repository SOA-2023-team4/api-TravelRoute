# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/distance'

module TravelRoute
  module Entity
    # Data structure for place information
    class Attraction < Dry::Struct
      include Dry.Types
      attr_accessor :description

      attribute :place_id,        Strict::String
      attribute :name,            Strict::String
      attribute :address,         Strict::String
      attribute? :description,    Strict::String.optional
      attribute? :type,           Strict::String.optional
      attribute? :opening_hours,  Strict::Hash.optional
      attribute :rating,          Coercible::Float.optional
      attribute :location,        Hash.optional

      def to_attr_hash # rubocop:disable Metrics/MethodLength
        {
          place_id:,
          name:,
          description:,
          address:,
          type:,
          opening_hours:,
          rating:,
          latitude:,
          longitude:
        }
      end

      def latitude
        location[:latitude]
      end

      def longitude
        location[:longitude]
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
