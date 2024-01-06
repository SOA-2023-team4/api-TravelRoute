# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class GeneratePlan
      include Dry::Transaction

      step :validate_input
      step :make_entity
      step :generate_distance_calculator
      step :create_plan

      private

      def validate_input(input)
        plan_req = input[:plan_req].call
        if plan_req.success?
          req = plan_req.value!
          Success(origin_index: req.origin_index, place_ids: req.place_ids)
        else
          Failure(plan_req.failure)
        end
      end

      # Expects input[:origin_index], input[:place_ids]
      def make_entity(input)
        attractions = ListAttractions.new.call(place_ids: input[:place_ids]).value!
        origin = attractions[input[:origin_index]]
        Success(origin:, attractions:)
      end

      def generate_distance_calculator(input)
        attractions = input[:attractions]
        distance_calculator = Mapper::DistanceCalculatorMapper.new(App.config.GMAP_TOKEN)
          .distance_calculator_for(attractions)
        input[:distance_calculator] = distance_calculator
        Success(input)
      rescue StandardError
        Failure('Could not generate distance calculator')
      end

      # need start_date_str, end_date_str, day_durations
      # day_durations specifies the time the day starts and ends
      # all the visit of attractions must be within the day_duration_time
      def create_plan(input)
        origin = input[:origin]
        planner = Entity::Planner.new(input[:attractions], input[:distance_calculator])
        day_durations = [
          [Value::Time.new(hour: 8, minute: 0), Value::Time.new(hour: 16, minute: 0)], 
          [Value::Time.new(hour: 8, minute: 0), Value::Time.new(hour: 16, minute: 0)]
        ]
        start_date_str = '2023-01-10'
        end_date_str = '2023-01-11'
        plan = planner.generate_plan(day_durations, start_date_str, end_date_str)
        Success(Response::ApiResult.new(status: :ok, message: plan))
      rescue StandardError
        Failure('Could not create plan')
      end
    end
  end
end
