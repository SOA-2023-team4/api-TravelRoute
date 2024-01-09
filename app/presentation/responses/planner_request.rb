# frozen_string_literal: true

module TravelRoute
  module Response
    PlanGenerateRequest = Struct.new :attractions,
                                     :distance_calculator,
                                     :day_durations,
                                     :start_date,
                                     :end_date,
                                     :start_time,
                                     :end_time,
                                     :id
  end
end
