# frozen_string_literal: true

module TravelRoute
  module Entity
    # dedicated to make plans using the information provided by the guidebook
    class Plan
      attr_reader :distance_calculator, :day_plans

      # day_durations: list of 2-value_list, each value_list is a tuple of start and end time
      def initialize(distance_calculator, day_durations, date_start, date_end)
        @distance_calculator = distance_calculator
        @day_durations = day_durations
        @date_start = Value::Date.new(date_start)
        @date_end = Value::Date.new(date_end)

        if (@date_end - @date_start) + 1 != day_durations.size
          raise StandardError, 'days of duration and dates must match'
        end

        @day_plans = day_durations
          .map.with_index { |dur, d| Entity::DayPlan.new(dur[0], dur[1], d, self) }
        @days = @day_durations.size
      end

      def opening_hours(attraction)
        start_index = @date_start.day_of_week_index
        opening_hours = []
        (start_index...start_index + @days).each do |i|
          opening_hour = attraction.week_opening_hour_on(i % Value::OpeningHours::DAYS_IN_WEEK)
          opening_hours.append(Value::OpeningHour.new(day_start: opening_hour.day_start, day_end: opening_hour.day_end))
        end
        Value::OpeningHours.new(opening_hours:)
      end

      def get(day)
        raise StandardError, 'Day out of range' if day >= @days

        @day_plans[day]
      end

      def can_append_attraction(day, attraction)
        raise StandardError, 'Day out of range' if day >= @days

        @day_plans[day].can_append_attraction(attraction)
      end

      def append_attraction(day, attraction)
        raise StandardError, 'Day out of range' if day >= @days

        @day_plans[day].append_attraction(attraction)
      end

      def pop_attraction(day)
        raise StandardError, 'Day out of range' if day >= @days

        @day_plans[day].pop_attraction
      end

      def to_list
        @day_plans.map(&:to_list)
      end
    end
  end
end
