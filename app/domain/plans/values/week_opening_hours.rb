# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'opening_hour'

module TravelRoute
  module Value
    # the class for holding week opening hours
    class WeekOpeningHours < Dry::Struct
      include Dry.Types
      DAYS_IN_WEEK = 7

      attribute :opening_hours, Strict::Array.of(OpeningHour)

      def on(day)
        raise ArgumentError, "Day #{day} is out of range" if day >= opening_hours.size || day.negative?

        @opening_hours[day]
      end
    end
  end
end
