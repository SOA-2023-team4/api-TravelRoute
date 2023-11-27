# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class AddAttraction
      include Dry::Transaction

      step :make_entity
      step :save_to_db

      private

      def make_entity(input)
        attraction = Entity::Attraction.new(input)

        Success(attraction)
      rescue StandardError
        Failure('Could not create attraction')
      end

      def save_to_db(input)
        selected = Repository::Attractions.update_or_create(input)

        Success(selected)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure('Could not save attraction to database')
      end
    end
  end
end
