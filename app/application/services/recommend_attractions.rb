# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class RecommendAttractions
      include Dry::Transaction

      step :validate_input
      step :search_attractions
      step :request_recommendation_worker

      private

      SEARCH_ERR = 'search attractions error'
      SEARCH_NEARBY_ERR = 'search nearby error'
      RECOMMENDATION_ERR = 'recommendation error'
      PROCESSING_MSG = 'Processing the summary request'

      def validate_input(input)
        recommendation_req = input[:recommendation_req].call
        if recommendation_req.success?
          req = recommendation_req.value!
          Success(ids: req[:ids], exclude: req[:exclude])
        else
          Failure(recommendation_req.failure)
        end
      end

      def search_attractions(input)
        ids = input[:ids]
        attractions = ids.map do |id|
          Concurrent::Promise.execute { AddAttraction.new.call(place_id: id).value!.message }
        end.map(&:value)
        # attractions = ids.map do |id|
        #   AddAttraction.new.call(place_id: id).value!.message
        # end
        input[:attractions] = attractions
        input[:exclude] ||= attractions.map(&:name)
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: SEARCH_ERR))
      end

      def request_recommendation_worker(input)
        attractions = input[:attractions]
        json = Representer::AttractionsList.new(Response::AttractionsList.new(attractions:)).to_json
        Messaging::Queue.new(App.config.RECOMMENDATION_QUEUE_URL, App.config).send(json)
        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: RECOMMENDATION_ERR))
      end
    end
  end
end
