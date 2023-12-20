# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'attraction'
require_relative '../values/duration'
require_relative '../values/distance'

module TravelRoute
  module Entity
    # Data structure for route information
    class AttractionWeb < Dry::Struct
      include Dry.Types

      attribute :hub, Attraction
      attribute :nodes, Strict::Array.of(Attraction)
    end
  end
end
