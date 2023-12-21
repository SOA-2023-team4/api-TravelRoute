# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Attraction -> Attraction entity
    class TourguideMapper
      def initialize(openai_key, gmap_token, gateway_class = OpenAi::Api)
        @key = openai_key
        @gmap_token = gmap_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def to_entity(attractions)
        Entity::TourGuide.new(
          attractions: attractions.map { |attraction| recommend_attraction(attraction) }
        )
      end

      def recommend_attraction(attraction)
        data = @gateway.get_recommendation(attraction.city, 3)
        AttractionWebDataMapper.new(attraction, data, @gmap_token).build_entity
      end

      # extract entity specific data
      class AttractionWebDataMapper
        def initialize(attraction, data, gmap_token)
          @attraction = attraction
          @data = data
          @gmap_token = gmap_token
        end

        def build_entity
          temp = attractions
          Entity::AttractionWeb.new(
            hub: @attraction,
            nodes: temp
          )
        end

        def attractions
          place_names.map do |place_name|
            AttractionMapper.new(@gmap_token).find(place_name).first
          end
        end

        def place_names
          JSON.parse(@data['choices'][0]['message']['content'])['places'].map { |place| place['name'] }
        end
      end
    end
  end
end
