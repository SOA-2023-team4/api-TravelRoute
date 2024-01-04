# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'time'
require_relative 'opening_hour'

module TravelRoute
  module Value
    # the class for holding continguous days (across weeks) opening hours
    class OpeningHours < Dry::Struct
      include Dry.Types

      attribute :opening_hours, Strict::Array.of(OpeningHour)

      def on(day)
        raise ArgumentError, "Day #{day} is out of range" if day >= opening_hours.size || day.negative?

        @opening_hours[day]
      end

      def to_attr_hash
        @opening_hours.map.with_index do |opening_hour, day|
          { day:, start: opening_hour.start.to_attr_hash, end: opening_hour.end.to_attr_hash }
        end
      end
    end
  end
end
