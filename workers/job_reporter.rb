# frozen_string_literal: true

require_relative 'progress_publisher'

module Background
  # Worker to report job status
  class JobReporter
    attr_reader :attractions, :id

    def initialize(config, request)
      req = TravelRoute::Representer::ReccommendationRequest.new(OpenStruct.new).from_json(request)
      @attractions = req.attractions
      @id = req.id
      @publisher = ProgressPublisher.new(config, @id)
      @prev_msg = ''
    end

    def report(msg = nil, &operation)
      puts block_given? ? operation.call : msg
      @publisher.publish(msg)
    end

    def report_when_changed(msg = nil)
      message = fetch_message(msg) { |block| yield block if block_given? }

      report(message) if changed?(message)
      @prev_msg = message
    end

    def report_every_second(num = 5, &operation)
      num.times do
        report(operation.call)
        sleep 1
      end
    end

    private

    def fetch_message(default_msg, &operation)
      block_given? ? operation.call : default_msg
    end

    def changed?(msg)
      msg != @prev_msg
    end
  end
end
