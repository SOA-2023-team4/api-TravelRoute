# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class RecommendAttractions
      include Dry::Transaction

      step :database_lookup
      step :google_api_lookup
      step :make_recommendations

      private

      DB_ERR = 'Cannot access database'
      API_ERR = 'Cannot access Google API'
      NOT_FOUND = 'Attraction not found'
      INT_ERR = 'Internal error'

      def database_lookup(input)
        input[:attraction] = Repository::Attractions.find_id(input[:place_id])
        Success(input)
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end

      def google_api_lookup(input)
        return Success(input) if input[:attraction]

        attraction = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(input[:place_id])
        return Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND)) unless attraction

        Success(input.merge(attraction:))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: API_ERR))
      end

      def make_recommendations(input)
        attraction = input[:attraction]
        latitude = attraction.location[:latitude]
        longitude = attraction.location[:longitude]
        attractions = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).places_nearby(latitude, longitude)
        attractions_list = Response::AttractionsList.new(attractions)
        Success(Response::ApiResult.new(status: :ok, message: attractions_list))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: INT_ERR))
      end
    end
  end
end