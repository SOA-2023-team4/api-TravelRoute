# frozen_string_literal: true

require_relative 'route_attraction'

module Views
  # View object for plan
  class Plan
    attr_reader :plan, :name

    def initialize(plan, name = 'Untitled')
      @plan = plan
      @name = name
    end

    def all_attractions
      @plan.attractions
    end

    def origin
      @plan.attractions.first
    end

    def route_to_attractions
      @plan.routes.zip(@plan.attractions[1..]).map do |route, attraction|
        RouteAttraction.new(route, attraction)
      end
    end
  end
end
