# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/address'

module TravelRoute
  module Entity
    # Data structure for place information
    class Attraction < Dry::Struct
      include Dry.Types

      attribute :place_id,        Strict::String
      attribute :name,            Strict::String
      attribute :address,         Strict::String
      attribute? :description,    Strict::String.optional
      attribute? :type,           Strict::String.optional
      attribute? :stay_time,      Strict::Integer.optional
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
          stay_time:,
          rating:,
          location:
        }
      end

      def latitude
        location[:latitude]
      end

      def longitude
        location[:longitude]
      end

      def country
        Value::Address.new(address).country
      end

      def city
        Value::Address.new(address).city
      end

      def reccommendation_prompt(num = 3, exclude = nil)
        Value::OpenAiPrompt.reccommendation_prompt(self, num, exclude)
      end

      def time_to_stay_prompt
        Value::OpenAiPrompt.time_to_stay_prompt(self)
      end

      def filled?
        Value::SuggestedValue.new(stay_time, description).present?
      end
    end
  end
end
