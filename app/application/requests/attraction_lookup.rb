# frozen_string_literal: true

module TravelRoute
  module Request
    # Application value for the attraction with place_id
    class AttractionLookup
      attr_reader :place_id

      def initialize(place_id)
        @place_id = place_id
      end
    end
  end
end
