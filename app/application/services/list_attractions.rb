# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class ListAttractions
      include Dry::Monads::Result::Mixin

      # Expects input[:place_ids]
      def call(input)
        attractions = input[:place_ids].map do |place_id|
          AddAttraction.new.call(place_id:).value!.message
        end.map(&:value)

        Success(attractions)
      rescue StandardError
        Failure('Cannot access database')
      end
    end
  end
end
