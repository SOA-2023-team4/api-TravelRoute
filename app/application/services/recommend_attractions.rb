# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class RecommendAttractions
      include Dry::Transaction

      step :validate_input
      step :search_attractions
      step :make_recommendations

      private

      SEARCH_ERR = 'search attractions error'
      SEARCH_NEARBY_ERR = 'search nearby error'
      RECOMMENDATION_ERR = 'recommendation error'

      def validate_input(input)
        recommendation_req = input[:recommendation_req].call
        if recommendation_req.success?
          req = recommendation_req.value!
          Success(ids: req[:ids])
        else
          Failure(recommendation_req.failure)
        end
      end

      def search_attractions(input)
        ids = input[:ids]
        attractions = ids.map do |id|
          AddAttraction.new.call(place_id: id).value!.message
        end
        input[:attractions] = attractions
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: SEARCH_ERR))
      end

      # This logic should be in domain object
      def make_recommendations(input)
        attractions = input[:attractions]
        tourguide = TravelRoute::Mapper::TourguideMapper
          .new(App.config.OPENAI_API_KEY, App.config.GMAP_TOKEN)
          .to_entity(attractions)
        msg = Response::AttractionsList.new(tourguide.recommend_attractions)
        Success(Response::ApiResult.new(status: :ok, message: msg))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: RECOMMENDATION_ERR))
      end
    end
  end
end
