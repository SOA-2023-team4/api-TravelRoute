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

      def make_entity(input)
        cart = ListAttractions.new.call(input[:cart]).value!
        origin = cart.find { |attraction| attraction.place_id == input[:origin] }
        Success(cart:, origin:)
      end

      def generate_guidebook(input)
        guidebook = Mapper::GuidebookMapper.new(App.config.GMAP_TOKEN).generate_guidebook(input[:cart])

        Success(guidebook:, origin: input[:origin])
      rescue StandardError
        Failure('Could not generate guidebook')
      end

      def create_plan(input)
        plan = Entity::Planner.new(input[:guidebook]).generate_plan(input[:origin])

        Success(plan)
      rescue StandardError
        Failure('Could not create plan')
      end
    end
  end
end
