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

    def to_attr_hash
      { start: @start.to_attr_hash, end: @end.to_attr_hash }
    end
  end
end
