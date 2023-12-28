# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class LookUpAttraction
      include Dry::Monads::Result::Mixin

      def call(input)
        if (attraction = attraction_in_database(input))
          input[:local_attraction] = attraction
        else
          input[:remote_attraction] = attraction_from_api(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
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
      end
    end
  end
end
