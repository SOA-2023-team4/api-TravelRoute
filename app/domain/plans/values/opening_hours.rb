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
      # Needs to check if there are 7 days of opening hours
      attribute :opening_hours, Strict::Array.of(OpeningHour)

      NotOpen = OpeningHour.new(day_start: Time.new(25, 0), day_end: Time.new(-1, 0))

      # [[Time(8, 0), Time(16, 0)], [Time(8, 0), Time(16, 0)]...]
      def self.list_to_opening_hours(list)
        OpeningHours.new(opening_hours:
          list.map do |day|
            OpeningHour.new(day_start: day[0], day_end: day[1])
          end)
      end

      def on(day)
        raise ArgumentError, "Day #{day} is out of range" if day >= opening_hours.size || day.negative?

        opening_hours[day]
      end

      def to_attr_hash
        # (0..6).to_a.to_h do |i|
        #   [i, { day_start: opening_hours[i].day_start.to_attr_hash, day_end: opening_hours[i].day_end.to_attr_hash }]
        # end
        opening_hours
          .map.with_index { |h, i| [i, { day_start: h.day_start.to_attr_hash, day_end: h.day_end.to_attr_hash }] }
          .to_h
      end
    end
  end
end
