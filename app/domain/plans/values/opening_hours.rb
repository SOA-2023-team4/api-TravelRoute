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
    end
  end
end
