# frozen_string_literal: true

module TravelRoute
  module Mapper
    # Data Mapper: Google Maps Attraction -> Attraction entity
    class TourguideMapper
      def initialize(config, gateway_class = OpenAi::Api)
        @key = config.OPENAI_API_KEY
        @gmap_token = config.GMAP_TOKEN
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@key)
      end

      def to_entity(attractions, exclude = nil)
        exclude ||= attractions.map(&:name)
        Entity::TourGuide.new(
          attractions: attractions.map do |attraction|
            recommend_attraction(attraction, exclude) { |block| yield block if block_given? }
          end
        )
      end

      private

      def recommend_attraction(attraction, exclude = nil)
        exclude ||= [attraction.name]
        data = @gateway.get_recommendation(attraction, 3, exclude) { |block| yield block if block_given? }
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
          Entity::AttractionWeb.new(
            hub: @attraction,
            nodes: attractions
          )
        end

        def attractions
          places.map do |place|
            Concurrent::Promise.execute do
              attraction = AttractionMapper.new(@gmap_token).find(place[:name]).first
              attraction.description = place[:description]
              attraction
            end
          end.map(&:value)
        end

        def places
          # JSON.parse(@data['choices'][0]['message']['content'])['places']
          JSON.parse(@data, symbolize_names: true)[:places]
        end
      end
    end
  end
end
