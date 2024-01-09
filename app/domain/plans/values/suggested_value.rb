# frozen_string_literal: true

module TravelRoute
  module Value
    # class for hadling suggested value
    class SuggestedValue
      attr_reader :stay_time, :description

      def initialize(stay_time, description)
        @stay_time = stay_time
        @description = description
      end

      def present?
        !description.nil?
      end
    end
  end
end
