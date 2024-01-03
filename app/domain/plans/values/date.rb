# frozen_string_literal: true

require 'date'
DT = Date

module TravelRoute
  module Value
    DAY_MAPPING = {
      Sunday: 0,
      Monday: 1,
      Tuesday: 2,
      Wednesday: 3,
      Thursday: 4,
      Friday: 5,
      Saturday: 6
    }.freeze
    # Value object for indexing operations on attractions
    class Date
      attr_reader :date_string

      def initialize(date_string)
        @date_string = date_string
      end

      def day_of_week
        DT.parse(@date_string).strftime('%A')
      end

      def day_of_week_index
        DAY_MAPPING[day_of_week.to_sym]
      end

      def -(other)
        (DT.parse(@date_string) - DT.parse(other.date_string)).to_i
      end
    end
  end
end
