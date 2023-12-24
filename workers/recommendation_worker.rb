# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class RecommendationWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.RECOMMENDATION_QUEUE_URL, auto_delete: true

  # currently I can't think of a better way to do this
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def perform(_sqs_msg, request)
    structs = TravelRoute::Representer::AttractionsList.new(OpenStruct.new).from_json(request)
    place_ids = structs.attractions.map(&:place_id)
    attractions = place_ids.map do |place_id|
      TravelRoute::Mapper::AttractionMapper.new(self.class.config.GMAP_TOKEN).find_by_id(place_id)
    end
    tourguide = TravelRoute::Mapper::TourguideMapper.new(self.class.config.OPENAI_API_KEY, self.class.config.GMAP_TOKEN).to_entity(attractions)
    json = TravelRoute::Representer::AttractionsList.new(
      TravelRoute::Response::AttractionsList.new(attractions: tourguide.recommend_attractions)
    ).to_json
    key = place_ids.sort.join(' ')
    TravelRoute::Cache::Client.new(self.class.config).set(key, json)
    puts 'Recommendation request processed'
  rescue StandardError => e
    puts 'Error processing recommendation request'
    puts e
  end
end
