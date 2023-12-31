# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class LookUpAttraction
      include Dry::Monads::Result::Mixin

      DB_ERR_MSG = 'Having trouble accessing the database'
      NOT_FOUND_MSG = 'Could not find that attraction_id on Google Api'

      def call(input)
        input[:attraction] = attraction_in_database(input) || attraction_from_api(input)
        Success(input)
      rescue StandardError => err
        Failure(Response::ApiResult.new(status: :not_found, message: err.to_s))
      end

      # Support methods for steps
      def attraction_from_api(input)
        place_id = input[:place_id]
        Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
      rescue StandardError
        raise "#{NOT_FOUND_MSG}: #{place_id}"
      end

      def attraction_in_database(input)
        Repository::Attractions.find_id(input[:place_id])
      rescue StandardError
        raise DB_ERR_MSG
      end
    end
  end
end
