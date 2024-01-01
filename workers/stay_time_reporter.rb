# frozen_string_literal: true

require_relative 'progress_publisher'
require_relative 'lib/reporter'

module Background
  # Worker to report job status
  class StayTimeReporter
    include Mixins::Reporter

    attr_reader :attraction, :id

    def initialize(config, request)
      req = TravelRoute::Representer::StayTimeRequest.new(OpenStruct.new).from_json(request)
      @attraction = req.attraction
      @id = req.id
      @publisher = ProgressPublisher.new(config, @id)
      @prev_msg = ''
    end
  end
end
