# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class GeneratePlan
      include Dry::Transaction

      step :make_entity
      step :generate_guidebook
      step :create_plan

      private

      # Expects input[:place_ids] and input[:origin_index]
      def make_entity(input)
        place_ids = input[:place_ids]
        origin_index = input[:origin_index].to_i
        attractions = ListAttractions.new.call(place_ids:).value!
        input[:attractions] = attractions
        input[:origin] = attractions[origin_index]
        Success(input)
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
        plan = Entity::Plan.new(input[:guidebook]).generate_plan(origin)

        Success(plan)
      rescue StandardError
        Failure('Could not create plan')
      end
    end
  end
end
