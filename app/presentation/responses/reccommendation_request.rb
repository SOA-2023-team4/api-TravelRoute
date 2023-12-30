# frozen_string_literal: true

module TravelRoute
  module Response
    ReccommendationRequest = Struct.new :attractions, :exclude, :id
  end
end
