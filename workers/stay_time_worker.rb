# frozen_string_literal: true

require_relative '../require_app'
require_relative 'stay_time_reporter'
require_relative 'reccommendation_monitor'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
module Background
  # Shoryuken worker class to recommend attractions
  class StayTimeWorker
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
    shoryuken_options queue: config.STAYTIME_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = StayTimeReporter.new(self.class.config, request)
      attraction = TravelRoute::Entity::Attraction.new(**reformat(job.attraction.to_h))
      suggestion = request_time(attraction)
      TravelRoute::Repository::Attractions.update(
        TravelRoute::Entity::Attraction.new(**attraction.to_rebuild_hash.merge(suggestion))
      )
    end

    def request_time(attraction)
      chat = TravelRoute::OpenAi::Api.new(RecommendationWorker.config.OPENAI_API_KEY)
        .get_time_to_stay(attraction.time_to_stay_prompt)
      puts chat
      JSON.parse(chat, symbolize_names: true)
    end

    def reformat(hash)
      hash.merge({
                   opening_hours: rebuild_opening_hours(hash),
                   location: rebuild_location(hash)
      })
    end

    def rebuild_location(hash)
      TravelRoute::Value::Location.new(**hash[:location].to_h)
    end

    def rebuild_opening_hours(hash)
      hash[:opening_hours].to_h[:opening_hours]
        .map { |v| TravelRoute::Value::OpeningHour.new(day_start: v[:day_start].to_h, day_end: v[:day_end].to_h) }
        .then { TravelRoute::Value::OpeningHours.new(opening_hours: _1) }
    end
  end
end
