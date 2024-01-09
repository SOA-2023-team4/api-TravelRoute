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
      step :init_planner
      step :create_plan

      private

      def validate_input(input)
        plan_req = input[:plan_req].call
        if plan_req.success?
          req = plan_req.value!
          Success(request: req)
        else
          Failure(plan_req.failure)
        end
      end

      # Expects input[:origin_index], input[:place_ids]
      def make_entity(input)
        req = input[:request]
        attractions = ListAttractions.new.call(place_ids: req[:place_ids]).value!
        Success(req.merge(attractions:))
      end

      def generate_distance_calculator(input)
        attractions = input[:attractions]
        distance_calculator = Mapper::DistanceCalculatorMapper.new(App.config.GMAP_TOKEN)
          .distance_calculator_for(attractions)
        input[:distance_calculator] = distance_calculator
        Success(input.merge(distance_calculator:))
      rescue StandardError
        Failure('Could not generate distance calculator')
      end

      # need start_date_str, end_date_str, day_durations
      # day_durations specifies the time the day starts and ends
      # all the visit of attractions must be within the day_duration_time

      def init_planner(input)
        # origin = input[:origin]
        planner = Entity::Planner.new(input[:attractions], input[:distance_calculator])
        Success(input.merge(planner:))
      rescue StandardError
        Failure('Could not initialize planner')
      end

      def create_plan(input)
        day_durations = input[:day_durations]
        start_date_str = input[:start_date]
        end_date_str = input[:end_date]
        plan = input[:planner].generate_plan(day_durations, start_date_str, end_date_str)
        Success(Response::ApiResult.new(status: :ok, message: plan))
      rescue StandardError
        Failure('Could not create plan')
      end
    end
  end
end
