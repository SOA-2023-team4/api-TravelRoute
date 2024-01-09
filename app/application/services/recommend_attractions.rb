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
        input[:attractions] = input[:ids].map do |id|
          AddAttraction.new.call(place_id: id).value!.message
        end.map
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: SEARCH_ERR))
      end

      def request_recommendation_worker(input)
        request = RecommendationRequestHelper.new(input)
        return Success(Response::ApiResult.new(status: :ok, message: request.result)) if request.found?

        request.send_to_queue
        Failure(Response::ApiResult.new(
                  status: :processing,
                  message: { host: App.config.API_HOST, request_id: request.request_id, msg: PROCESSING_MSG }
                ))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: RECOMMENDATION_ERR))
      end

      # helper class
      class RecommendationRequestHelper
        def initialize(input)
          @input = input
        end

        def attractions
          @input[:attractions]
        end

        def exclude
          @input[:exclude] ||= attractions.map(&:name)
        end

        def request_id
          attractions.map(&:place_id).sort.join
        end

        def found?
          reccommended = Cache::Client.new(App.config).get(request_id)
          reccommended && !reccommended.empty?
        end

        def result
          result = Cache::Client.new(App.config).get(request_id)
          Representer::AttractionsList.new(Response::AttractionsList.new).from_json(result) if result
        end

        def send_to_queue
          json = Response::ReccommendationRequest.new(attractions:, exclude:, id: request_id)
            .then { Representer::ReccommendationRequest.new(_1) }
            .then(&:to_json)
          Messaging::Queue.new(App.config.RECOMMENDATION_QUEUE_URL, App.config).send(json)
        end
      end
    end
  end
end
