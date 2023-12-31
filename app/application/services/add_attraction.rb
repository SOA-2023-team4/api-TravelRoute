# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class AddAttraction
      include Dry::Transaction

      # step :find_attraction
      step :store_attraction

      private

      # Expects input[:place_id]
      # def find_attraction(input)
      #   Service::LookUpAttraction.new.call(input)
      # end

      def store_attraction(input)
        req = Service::LookUpAttraction.new.call(input)
        attraction = Repository::Attractions.update_or_create(req.value![:attraction])
        Success(Response::ApiResult.new(status: :ok, message: attraction))
      rescue StandardError => err
        App.logger.error("ERROR: #{err.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end
