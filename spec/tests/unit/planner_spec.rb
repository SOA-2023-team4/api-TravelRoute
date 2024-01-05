# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

# describe 'Unit test for planning' do
#   it 'verify 2-day plan with constraints' do
        # a0 = TravelRoute::Entity::Attraction.new(
    #   place_id: 'p0',
    #   name: 'p0',
    #   stay_time: Time.new(4, 0),
    #   # opening_hours: TravelRoute::Value::OpeningHours.new(
    #   #   opening_hours: [
    #   #     TravelRoute::Value::OpeningHour.new(day_start: Time.new(10, 0), day_end: Time.new(14, 0))
    #   #   ]),
    #   location: TravelRoute::Value::Location.new(lat: 0, lng: 0))
    # binding.irb

    # a1 = TravelRoute::Value::Attraction.new(
    #   place_id: 'p1',
    #   name: 'p1',
    #   stay_time: Time.new(3, 0),
    #   opening_hours: TravelRoute::Value::OpeningHours.new(
    #     opening_hours: [
    #       TravelRoute::Value::OpeningHour.new(day_start: Time.new(13, 0), day_end: Time.new(16, 0)),
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen
    #     ]),
    #   location: TravelRoute::Value::Location.new(lat: 0, lng: 0))
    # a2 = TravelRoute::Value::Attraction.new(
    #   place_id: 'p2',
    #   name: 'p2',
    #   stay_time: Time.new(3, 0),
    #   opening_hours: TravelRoute::Value::OpeningHours.new(
    #     opening_hours: [
    #       TravelRoute::Value::OpeningHour.new(day_start: Time.new(13, 0), day_end: Time.new(16, 0)),
    #       TravelRoute::Value::OpeningHour.new(day_start: Time.new(8, 0), day_end: Time.new(16, 0)),
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen,
    #       TravelRoute::Value::OpeningHours.NotOpen
    #     ]),
    #   location: TravelRoute::Value::Location.new(lat: 0, lng: 0)
    # )
    # attractions = [a0, a1, a2]
    # binding.irb
    # a_count = attractions.size
    # distance_calculator = DistanceCalculator(attractions, Array.new(a_count, Array.new(a_count, Time(0, 0))))
    # day_durations = [[Time(8, 0), Time(16, 0)], [Time(8, 0), Time(16, 0)]]
    # generated_plans = TravelRoute::Entity::Planner.new(distance_calculator)
    #   .generate_plans(attractions, day_durations, '2023/12/24', '2023/12/25')

    # puts generated_plans
#   end
# end
