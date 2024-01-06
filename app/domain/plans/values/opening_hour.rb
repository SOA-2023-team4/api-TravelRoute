# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Value
    # class for converting opening hours to a value object
    class OpeningHour < Dry::Struct
      include Dry.Types
      attribute :day_start, Time
      attribute :day_end, Time

      def self.NOT_OPEN
        OpeningHour.new(day_start: Time.new(hour: 25, minute: 0), day_end: Time.new(hour: -1, minute: 0))
      end

      def to_attr_hash
        { day_start: day_start.to_attr_hash, day_end: day_end.to_attr_hash }
      end
    end
  end
end
