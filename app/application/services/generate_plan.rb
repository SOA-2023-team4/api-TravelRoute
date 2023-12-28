# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class GeneratePlan
      include Dry::Transaction

      step :validate_input
      step :make_entity
      step :generate_guidebook
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

      def generate_guidebook(input)
        attractions = input[:attractions]
        guidebook = Mapper::GuidebookMapper.new(App.config.GMAP_TOKEN).generate_guidebook(attractions)
        input[:guidebook] = guidebook
        Success(input)
      rescue StandardError
        Failure('Could not generate guidebook')
      end

      def create_plan(input)
        origin = input[:origin]
        plan = Entity::Plan.new(input[:guidebook], origin)

        Success(Response::ApiResult.new(status: :ok, message: plan))
      rescue StandardError
        Failure('Could not create plan')
      end
    end
  end
end
