# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TravelRoute
  module Entity
    # Data structure for place information
    class Place < Dry::Struct
      include Dry.Types

      attribute :id,      Strict::String
      attribute :name,    Strict::String
      attribute :address, Strict::String
      attribute :rating,  Coercible::Float
    end
  end
end
