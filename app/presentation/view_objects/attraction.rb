# frozen_string_literal: true

module Views
  # View object for attraction
  class Attraction
    # Error for invalid search term
    class InvalidSearchTerm < StandardError
      def message
        'Invalid search term'
      end
    end

    def initialize(attraction)
      @attraction = attraction
    end

    def place_id
      @attraction.place_id
    end

    def name
      @attraction.name
    end

    def address
      @attraction.address
    end

    def rating
      @attraction.rating
    end

    def to_json(options = {})
      {
        place_id:,
        name:,
        address:,
        rating:
      }.to_json(options)
    end
  end
end
