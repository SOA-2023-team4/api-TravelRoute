# frozen_string_literal: true

require 'dry/transaction'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class AddAttraction
      include Dry::Transaction

      DB_ERR_MSG = 'Having trouble accessing the database'

      # step :find_attraction
      step :store_attraction
      step :request_time_to_stay

      private

      # Expects input[:place_id]
      # def find_attraction(input)
      #   Service::LookUpAttraction.new.call(input)
      # end

      def store_attraction(input)
        req = Service::LookUpAttraction.new.call(input)
        attraction = Repository::Attractions.update_or_create(req.value![:attraction])
        Success(attraction:)
      rescue StandardError => err
        App.logger.error("ERROR: #{err.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def request_time_to_stay(input)
        attraction = input[:attraction]
        return Success(Response::ApiResult.new(status: :ok, message: attraction)) if attraction.filled?

        json = Response::StayTimeRequest.new(attraction:, id: attraction.place_id)
          .then { Representer::StayTimeRequest.new(_1) }
          .then(&:to_json)
        Messaging::Queue.new(App.config.STAYTIME_QUEUE_URL, App.config).send(json)

        Success(Response::ApiResult.new(status: :processing, message: attraction))
      end
    end
  end
end
