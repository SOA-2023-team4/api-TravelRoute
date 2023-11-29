# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class AddAttraction
      include Dry::Transaction

      step :validate_body
      step :make_entity
      step :save_to_db

      private

      def validate_body(input)
        body = input.call
        if body.success?
          Success(body.value!)
        else
          Failure(body.failure)
        end
      end

      def make_entity(input)
        attraction = Entity::Attraction.new(input)

        Success(attraction)
      rescue StandardError
        Failure('Could not create attraction')
      end

      def save_to_db(input)
        Repository::Attractions.update_or_create(input)
          .then { |attraction| Response::ApiResult.new(status: :created, message: attraction) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure('Could not save attraction to database')
      end
    end
  end
end
