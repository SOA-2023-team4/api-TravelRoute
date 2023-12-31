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

        def initialize(api_key)
          @key = api_key
        end

        def places_from_text_data(search_text)
          fields = FIELDS.map { |field| "places.#{field}" }
          body = { 'textQuery' => search_text }
          url = place_endpoint(':searchText')
          Http::Request.post(url, headers(fields), body).parse
        end

        def place_detail_data(place_id)
          url = place_endpoint("/#{place_id}")
          Http::Request.get(url, headers(FIELDS)).parse
        end

        def places_nearby(latitude, longitude, type)
          raise 'place type not supported' unless VALID_TYPES.keys.include?(type)

          nearby = PlacesNearBy.new(latitude, longitude, type)
          url = place_endpoint(':searchNearby')
          Http::Request.post(url, headers(nearby.fields), nearby.body).parse
        end

        private

        def headers(fields)
          {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': @key,
            'X-Goog-FieldMask': fields.join(',')
          }
        end

        def place_endpoint(endpoint)
          "#{PLACE_ROOT_PATH}#{endpoint}"
        end

        # class for places nearby
        class PlacesNearBy
          MAX_RECOMMENDATION_RESULT = 10
          RADIUS = 1000
          VALID_TYPES = {
            'restaurant' => %w[restaurant cafe],
            'attraction' => %w[amusement_park aquarium art_gallery museum park shopping_mall zoo tourist_attraction],
            'hotel'      => ['lodging']
          }.freeze

          def initialize(latitude, longitude, type)
            @latitude = latitude
            @longitude = longitude
            @type = type
          end

          def body
            {
              includedPrimaryTypes: VALID_TYPES[@type],
              maxResultCount: MAX_RECOMMENDATION_RESULT,
              locationRestriction: {
                circle: {
                  center: { latitude: @latitude, longitude: @longitude},
                  radius: RADIUS
                }
              }
            }
          end

          def fields = FIELDS.map { |field| "places.#{field}" }
        end
      end
    end
  end
end
