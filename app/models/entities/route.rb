# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'place'

module TravelRoute
  module Entity
    # Data structure for route information
    class Route < Dry::Struct
      include Dry.Types

      attribute :origin,          Place
      attribute :destination,     Place
      attribute :distance_meters, Strict::Integer
      attribute :duration,        Strict::Integer
    end
  end
end
