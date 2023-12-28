# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class AddAttraction
      include Dry::Transaction

      step :find_attraction
      step :store_attraction

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      NOT_FOUND_MSG = 'Could not find that attraction_id on Google Api'

      # Expects input[:place_id]
      def find_attraction(input)
        Service::LookUpAttraction.new.call(input)
      end

      def store_attraction(input)
        attraction =
          if (new_attraction = input[:remote_attraction])
            Repository::Attractions.create(new_attraction)
          else
            input[:local_attraction]
          end
        Success(Response::ApiResult.new(status: :ok, message: attraction))
      rescue StandardError => e
        App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end
