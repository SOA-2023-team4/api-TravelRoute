# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class SearchAttractions
      include Dry::Transaction

      step :validate_search
      step :retrieve_attractions

      private

      API_ERR = 'Cannot access Google Maps API'

      def validate_search(input)
        search = input.call
        if search.success?
          Success(search.value!)
        else
          Failure(seach.failure)
        end
      end

      def retrieve_attractions(input)
        Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find(input)
          .then { |attractions| Response::AttractionsList.new(attractions) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: API_ERR)
        )
      end
    end
  end
end
