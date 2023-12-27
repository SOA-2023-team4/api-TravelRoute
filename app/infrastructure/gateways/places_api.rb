# frozen_string_literal: true

require 'http'

require_relative 'request'
require_relative 'response'

module TravelRoute
  module GoogleMaps
    module Places
      # Api calling the google maps places api
      class Api
        PLACE_ROOT_PATH = 'https://places.googleapis.com/v1/places'
        FIELDS = %w[id displayName formattedAddress rating regularOpeningHours primaryType location].freeze
        MAX_RECOMMENDATION_RESULT = 10
        RADIUS = 1000
        VALID_TYPES = {
          'restaurant' => %w[restaurant cafe],
          'attraction' => %w[amusement_park aquarium art_gallery museum park shopping_mall zoo tourist_attraction],
          'hotel'      => ['lodging']
        }.freeze

        def initialize(api_key)
          @key = api_key
        end

        def create_headers(fields)
          {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': @key,
            'X-Goog-FieldMask': fields.join(',')
          }
        end

        def place_endpoint(endpoint)
          "#{PLACE_ROOT_PATH}#{endpoint}"
        end

        def places_from_text_data(search_text)
          fields = FIELDS.map { |field| "places.#{field}" }
          headers = create_headers(fields)
          body = { 'textQuery' => search_text }
          url = place_endpoint(':searchText')
          Http::Request.post(url, headers, body).parse
        end

        def place_detail_data(place_id)
          headers = create_headers(FIELDS)
          url = place_endpoint("/#{place_id}")
          Http::Request.get(url, headers).parse
        end

        def places_nearby_body(latitude, longitude, type)
          {
            includedPrimaryTypes: VALID_TYPES[type],
            maxResultCount: MAX_RECOMMENDATION_RESULT,
            locationRestriction: {
              circle: {
                center: { latitude:, longitude: },
                radius: RADIUS
              }
            }
          }
        end

        def places_nearby(latitude, longitude, type)
          raise 'place type not supported' unless VALID_TYPES.keys.include?(type)

          url = place_endpoint(':searchNearby')
          fields = FIELDS.map { |field| "places.#{field}" }
          headers = create_headers(fields)
          body = places_nearby_body(latitude, longitude, type)
          Http::Request.post(url, headers, body).parse
        end
      end
    end
  end
end
