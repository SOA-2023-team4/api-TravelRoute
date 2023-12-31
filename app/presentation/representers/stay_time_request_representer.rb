# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module TravelRoute
  module Representer
    # Representer object for project clone requests
    class StayTimeRequest < Roar::Decorator
      include Roar::JSON

      property :attraction, extend: Representer::Attraction, class: OpenStruct
      property :id
    end
  end
end
