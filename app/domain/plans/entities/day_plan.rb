# frozen_string_literal: true

module TravelRoute
  module Entity
    # child of Plan object
    class DayPlan
      attr_reader :visit_durations, :day_start, :day_end, :date

      def initialize(day_start, day_end, day, date, parent_plan)
        @day_start = day_start
        @day_end = day_end
        @day = day
        @date = date
        @plan = parent_plan
        @distance_calculator = @plan.distance_calculator
        @visit_durations = []
      end

      def _opening_hours(attraction)
        @plan.opening_hours(attraction)
      end

      def _start_time(attraction)
        day_start = @visit_durations.empty? ? @day_start : @visit_durations[-1].end
        [day_start, _opening_hours(attraction).on(@day).day_start].max
      end

      def can_append_attraction(attraction)
        start_time = _start_time(attraction)
        unless @visit_durations.empty?
          start_time += @distance_calculator.calculate(@visit_durations[-1].attraction, attraction)
        end
        # day related constraints
        pass_bed_time = start_time + attraction.stay_time > @day_end

        # attraction related constraints
        not_enough_time = start_time + attraction.stay_time > _opening_hours(attraction).on(@day).day_end

        return false if pass_bed_time || not_enough_time

        true
      end

      def append_attraction(attraction)
        start_time = _start_time(attraction)
        unless @visit_durations.empty?
          start_time += @distance_calculator.calculate(@visit_durations[-1].attraction, attraction)
        end
        visit_duration = VisitDuration.new(start_time, attraction)
        @visit_durations.append(visit_duration)
      end

      def pop_attraction
        @visit_durations.pop
      end

      def to_list
        @visit_durations.map { |vd| [vd.attraction.place_id, vd.start, vd.end] }
      end
    end
  end
end
