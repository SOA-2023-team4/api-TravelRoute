# frozen_string_literal: true

class Route
  def initialize(route_data)
    @route = route_data
  end

  def origin_name
    @route['origin']['name']
  end

  def origin_id
    @route['origin']['id']
  end

  def destination_name
    @route['destination']['name']
  end

  def destination_id
    @route['destination']['id']
  end

  def distance_meters
    @route['distanceMeters']
  end

  def duration
    @route['duration']
  end

  def polyline
    @route['polyline']['encodedPolyline']
  end
end
