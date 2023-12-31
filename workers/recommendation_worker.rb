# frozen_string_literal: true

require_relative '../require_app'
require_relative 'reccommendation_reporter'
require_relative 'reccommendation_monitor'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
module Background
  # Shoryuken worker class to recommend attractions
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
    def perform(_sqs_msg, request)
      job = ReccommendationReporter.new(self.class.config, request)
      attractions = reconstruct_attraction(job.attractions)

      job.report(ReccommendationMonitor.init_percent)
      recommend(attractions, job.exclude, job.id) do |stream|
        job.report_when_changed { ReccommendationMonitor.count(stream) }
      end
      job.report(ReccommendationMonitor.fininsed_percent)
    rescue StandardError => e
      puts 'Error processing recommendation request'
      puts e
    end

    private

    def recommend(attractions, exclude, key, &operation)
      tourguide = TravelRoute::Mapper::TourguideMapper.new(RecommendationWorker.config)
        .to_entity(attractions, exclude) do |stream|
          operation.call(stream)
        end

      json = TravelRoute::Representer::AttractionsList.new(
        TravelRoute::Response::AttractionsList.new(attractions: tourguide.recommend_attractions)
      ).to_json
      TravelRoute::Cache::Client.new(self.class.config).set(key, json)
    end

    def reconstruct_attraction(struct)
      struct.map do |attr|
        attr = symbolize_keys(attr)
        TravelRoute::Entity::Attraction.new(**attr)
      end
    end

    def symbolize_keys(hash)
      hash.to_h.transform_keys(&:to_sym).transform_values do |v|
        v.is_a?(Hash) ? v.transform_keys(&:to_sym) : v
      end
    end
  end
end
