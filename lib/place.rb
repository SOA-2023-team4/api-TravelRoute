# frozen_string_literal: true

class Place
  def initialize(place_data)
    @place = place_data
  end

  def id
    @place['place_id']
  end

  def name
    @place['name']
  end

  def rating
    @place['rating']
  end
end
