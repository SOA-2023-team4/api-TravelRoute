# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Value
    # class for time in a current day or duration
    class Time < Dry::Struct
      include Dry.Types
      include Comparable

      attribute :hour, Strict::Integer
      attribute :minute, Strict::Integer

      def to_minutes
        (hour * 60) + minute
      end

      def to_s
        "#{hour}:#{minute}"
      end

      def to_attr_hash
        { hour:, minute: }
      end

      def -(other)
        minutes = to_minutes - other.to_minutes
        Time.new(hour: minutes / 60, minute: minutes % 60)
      end

      def +(other)
        minutes = to_minutes + other.to_minutes
        Time.new(hour: minutes / 60, minute: minutes % 60)
      end

      def <=>(other)
        to_minutes <=> other.to_minutes
      end

      def ==(other)
        hour == other.hour && minute == other.minute
      end
    end
  end
end
