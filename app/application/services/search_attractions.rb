# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class SearchAttractions
      include Dry::Monads::Result::Mixin

      def call(search_term)
        candidates = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find(search_term)

        Success(candidates)
      rescue StandardError
        Failure('Could not connect to Google Maps API')
      end
    end
  end
end
