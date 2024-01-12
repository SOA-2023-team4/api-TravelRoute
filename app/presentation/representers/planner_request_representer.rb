# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module TravelRoute
  module Representer
    # Representer object for project clone requests
    class PlanGenerateRequest < Roar::Decorator
      include Roar::JSON

      collection :attractions, extend: Representer::Attraction, class: OpenStruct
      property :day_durations
      property :start_date
      property :end_date
      property :start_time
      property :end_time
      property :id
    end
  end
end
