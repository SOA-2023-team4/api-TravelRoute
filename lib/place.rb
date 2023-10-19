# frozen_string_literal: true

module TravelRoute
  # Data structure for place information
  class Place
    def initialize(place_data)
      @place = place_data
    end

    def id
      @place['place_id']
    end

    def name
      @place['name']
    end

    def formatted_address
      @place['formatted_address']
    end

    def rating
      @place['rating']
    end
  end
end
