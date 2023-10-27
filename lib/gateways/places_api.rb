# frozen_string_literal: true

require 'http'

require_relative 'request'
require_relative 'response'

module TravelRoute
  module GoogleMaps
    module Places
      # Api calling the google maps places api
      class Api
        PLACE_SEARCH_PATH = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
        PLACE_DETAIL_PATH = 'https://maps.googleapis.com/maps/api/place/details/json'

        def initialize(api_key)
          @key = api_key
        end

        def places_from_text_data(search_text)
          fields = %w[place_id name]
          esscpaed_text = CGI.escape(search_text)
          url = "#{PLACE_SEARCH_PATH}?fields=#{fields.join(',')}&input=#{esscpaed_text}&inputtype=textquery&key=#{@key}"
          Request.get(url).parse
        end

        def place_detail_data(place_id)
          fields = %w[name place_id rating formatted_address]
          url = "#{PLACE_DETAIL_PATH}?fields=#{fields.join(',')}&place_id=#{place_id}&key=#{@key}"
          Request.get(url).parse
        end
      end
    end
  end
end
