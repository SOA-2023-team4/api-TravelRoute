# frozen_string_literal: true

class Route
  def initialize(route_data)
    @route = route_data
  end

  def origin_id
    @route['origin_id']
  end

  def destination_id
    @route['destination_id']
  end

  def distanceMeters
    @route['distanceMeters']
  end

  def duration
    @route['duration']
  end

  def polyline
    @route['polyline']['encodedPolyline']
  end
end
