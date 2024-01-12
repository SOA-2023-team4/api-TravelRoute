# frozen_string_literal: true

require_relative 'progress_publisher'
require_relative 'lib/reporter'

module Background
  # Worker to report job status
  class PlannerReporter
    include Mixins::Reporter

    attr_reader :req, :id

    def initialize(config, request)
      @req = TravelRoute::Representer::PlanGenerateRequest.new(OpenStruct.new).from_json(request)
      @id = req.id
      @publisher = ProgressPublisher.new(config, @id)
      @prev_msg = ''
    end
  end
end
