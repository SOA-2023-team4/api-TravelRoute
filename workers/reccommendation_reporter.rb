# frozen_string_literal: true

require_relative 'progress_publisher'
require_relative 'lib/reporter'

module Background
  # Worker to report job status
  class ReccommendationReporter
    include Mixins::Reporter

    attr_reader :attractions, :id, :exclude

    def initialize(config, request)
      req = TravelRoute::Representer::ReccommendationRequest.new(OpenStruct.new).from_json(request)
      @attractions = req.attractions
      @exclude = req.exclude
      @id = req.id
      @publisher = ProgressPublisher.new(config, @id)
      @prev_msg = ''
    end
  end
end
