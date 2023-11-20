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

        def place_enpoint(endpoint)
          "#{PLACE_ROOT_PATH}#{endpoint}"
        end

        def text_query(search_text)
          {
            'textQuery' => search_text
          }
        end

        def places_from_text_data(search_text)
          fields = %w[places.displayName places.id places.formattedAddress places.rating places.regularOpeningHours]
          headers = create_headers(fields)
          body = text_query(search_text)
          url = place_enpoint(':searchText')
          Request.post(url, headers, body).parse
        end

        def place_detail_data(place_id)
          fields = %w[id displayName formattedAddress rating regularOpeningHours]
          headers = create_headers(fields)
          url = place_enpoint("/#{place_id}")
          Request.get(url, headers).parse
        end
      end
    end
  end
end
