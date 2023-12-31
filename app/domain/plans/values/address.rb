# frozen_string_literal: true

require_relative '../lib/distance_estimator'

module TravelRoute
  module Value
    # Value of route's distance
    class Address
      def initialize(address)
        @address = address
      end

      def country
        @address.split(',').last.strip
      end

      def city
        @address.split(',')[-2].strip
      end
    end
  end
end
