# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Value
    # class for converting opening hours to a value object
    class OpeningHour < Dry::Struct
      include Dry.Types
      attribute :day_start, Time
      attribute :day_end, Time
    end

    def to_attr_hash
      { day_start: day_start.to_attr_hash, day_end: day_end.to_attr_hash }
    end
  end
end
