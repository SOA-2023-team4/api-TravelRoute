# frozen_string_literal: true

require 'dry/monads'

module TravelRoute
  module Service
    # Retrieves array of all listed attraction entities
    class SearchAttractions
      include Dry::Transaction

      step :validate_search
      step :retrieve_attractions
      step :store_attractions

      private

      API_ERR = 'Cannot access Google Maps API'
      DB_ERR_MSG = 'Having trouble accessing the database'

      def validate_search(input)
        search_req = input[:search_req].call
        if search_req.success?
          Success(input.merge(search_term: search_req.value!))
        else
          Failure(search_req.failure)
        end
      end

      def retrieve_attractions(input)
        search_term = input[:search_term]
        attractions = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find(search_term)
        input[:attractions] = attractions
        Success(input)
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: API_ERR)
        )
      end

      def store_attractions(input)
        attractions = input[:attractions]
        input[:attractions].each do |attraction|
          Repository::Attractions.find_or_create(attraction)
        end
        attraction_list = Response::AttractionsList.new(attractions)
        Success(Response::ApiResult.new(status: :ok, message: attraction_list))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG)
        )
      end
    end
  end
end
