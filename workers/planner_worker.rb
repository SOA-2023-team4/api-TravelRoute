# frozen_string_literal: true

require_relative '../require_app'
require_relative 'planner_reporter'
require_relative 'planner_monitor'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
module Background
  # Shoryuken worker class to recommend attractions
  class PlannerWorker
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
    shoryuken_options queue: config.PLAN_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = PlannerReporter.new(self.class.config, request)

      job.report(PlannerMonitor.init_percent)
      PlannerWorkerHelper.new(self.class.config, job.req, job.id).store
      job.report(PlannerMonitor.fininsed_percent)

      # plan.store
    end

    # helper class
    class PlannerWorkerHelper
      def initialize(config, params, id)
        @id = id
        @config = config
        @params = params
        @attractions = @params.attractions
        @start_date = @params.start_date
        @end_date = @params.end_date
        @day_durations = @params.day_durations
      end

      def plan
        @plan ||= planner.generate_plan(day_durations, @start_date, @end_date)
      end

      def distance_calculator
        @distance_calculator ||= TravelRoute::Mapper::DistanceCalculatorMapper.new(@config.GMAP_TOKEN)
          .distance_calculator_for(attractions)
      end

      def planner
        @planner ||= TravelRoute::Entity::Planner.new(attractions, distance_calculator)
      end

      def attractions
        @attractions.map do |attraction|
          attr_hash = reformat(attraction.to_h)
          TravelRoute::Entity::Attraction.new(attr_hash)
        end
      end

      def store
        json = TravelRoute::Representer::Plan.new(
          TravelRoute::Response::Plan.new(day_plans: plan.day_plans)
        ).to_json
        TravelRoute::Cache::Client.new(@config).set(@id, json)
      end

      def day_durations
        @day_durations.map do |day_duration|
          start_time = Time.parse(day_duration[0])
          end_time = Time.parse(day_duration[1])

          [TravelRoute::Value::Time.new(hour: start_time.hour, minute: start_time.min),
           TravelRoute::Value::Time.new(hour: end_time.hour, minute: end_time.min)]
        end
      end

      private

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
end
