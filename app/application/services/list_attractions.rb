# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class ListAttractions
      include Dry::Monads::Result::Mixin

      def call(places_id)
        attractions = places_id.map do |place_id|
          Repository::Attractions.find_id(place_id)
        end

        Success(attractions)
      rescue StandardError
        Failure('Cannot access database')
      end
    end
  end
end
