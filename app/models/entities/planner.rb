# frozen_string_literal: true

require_relative 'guidebook'

module TravelRoute
  module Entity
    # aggregate to lookup for place info and routes info
    class Planner
      def initialize(guidebook)
        raise 'Planning attractions that are more than 20 is not supported' if guidebook.attraction_count > 20

        @guidebook = guidebook
        @graph = @guidebook.to_matrix
      end

      def generate_plan
        puts guidebook.to_matrix
      end
    end
  end
end
