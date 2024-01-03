# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Value
    # class for converting opening hours to a value object
    class OpeningHour < Dry::Struct
      include Dry.Types
      attribute :start, Time
      attribute :end, Time
    end
  end
end
