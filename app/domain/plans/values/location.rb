# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Value
    # class for time in a current day or duration
    class Location < Dry::Struct
      include Dry.Types

      attribute :latitude, Coercible::Float
      attribute :longitude, Coercible::Float

      def to_attr_hash
        { latitude:, longitude: }
      end
    end
  end
end
