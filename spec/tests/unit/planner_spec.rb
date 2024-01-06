# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

describe 'Unit test for planning' do
  it 'verify 1-day plan with constraints' do
    a0 = TravelRoute::Entity::Attraction.new(
      place_id: '0',
      name: 'p0',
      address: 'addr0',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 3, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 11, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    a1 = TravelRoute::Entity::Attraction.new(
      place_id: '1',
      name: 'p1',
      address: 'addr1',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 2, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 11, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 13, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    a2 = TravelRoute::Entity::Attraction.new(
      place_id: '2',
      name: 'p2',
      address: 'addr2',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 2, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 14, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    attractions = [a0, a1, a2]
    a_count = attractions.size
    distance_calculator = TravelRoute::Entity::DistanceCalculator.new(attractions, Array.new(a_count, Array.new(a_count, TravelRoute::Value::Time.new(hour: 0, minute: 0))))
    day_durations = [[TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]]
    generated_plans = TravelRoute::Entity::Planner.new(attractions, distance_calculator)
      .generate_plans(day_durations, '2023/12/24', '2023/12/24')

    plan0 = [
      [
        ['0', TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value:: Time.new(hour: 11, minute: 0)],
        ['1', TravelRoute::Value::Time.new(hour: 11, minute: 0), TravelRoute::Value::Time.new(hour: 13, minute: 0)],
        ['2', TravelRoute::Value::Time.new(hour: 14, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
      ]
    ]
    _(generated_plans[0].to_list).must_equal(plan0)
  end
  it 'verify 2-day plan with constraints' do
    a0 = TravelRoute::Entity::Attraction.new(
      place_id: '0',
      name: 'p0',
      address: 'addr0',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 4, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 10, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 14, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )

    a1 = TravelRoute::Entity::Attraction.new(
      place_id: '1',
      name: 'p1',
      address: 'addr1',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 3, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 13, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )

    a2 = TravelRoute::Entity::Attraction.new(
      place_id: '2',
      name: 'p2',
      address: 'addr2',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 3, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    attractions = [a0, a1, a2]
    a_count = attractions.size
    distance_calculator = TravelRoute::Entity::DistanceCalculator.new(attractions, Array.new(a_count, Array.new(a_count, TravelRoute::Value::Time.new(hour: 0, minute: 0))))
    day_durations = [
      [TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)],
      [TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
    ]
    generated_plans = TravelRoute::Entity::Planner.new(attractions, distance_calculator)
      .generate_plans(day_durations, '2023/12/24', '2023/12/25')

    plan0 = [
      [
        ['2', TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value:: Time.new(hour: 11, minute: 0)],
        ['1', TravelRoute::Value::Time.new(hour: 13, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
      ],
      [['0', TravelRoute::Value::Time.new(hour: 10, minute: 0), TravelRoute::Value::Time.new(hour: 14, minute: 0)]]
    ]
    _(generated_plans[0].to_list).must_equal(plan0)
  end
  it 'verify 3-day plan across weeks' do
    a0 = TravelRoute::Entity::Attraction.new(
      place_id: '0',
      name: 'p0',
      address: 'addr0',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 3, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 11, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 14, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 11, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 14, minute: 0)
          )
        ]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )

    a1 = TravelRoute::Entity::Attraction.new(
      place_id: '1',
      name: 'p1',
      address: 'addr1',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 3, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 13, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )

    a2 = TravelRoute::Entity::Attraction.new(
      place_id: '2',
      name: 'p2',
      address: 'addr2',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 2, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 8, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 16, minute: 0)
          )
        ]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    a3 = TravelRoute::Entity::Attraction.new(
      place_id: '3',
      name: 'p3',
      address: 'addr3',
      rating: 4.5,
      stay_time: TravelRoute::Value::Time.new(hour: 6, minute: 0),
      opening_hours: TravelRoute::Value::OpeningHours.new(
        opening_hours: [
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.NOT_OPEN,
          TravelRoute::Value::OpeningHour.new(
            day_start: TravelRoute::Value::Time.new(hour: 9, minute: 0),
            day_end: TravelRoute::Value::Time.new(hour: 15, minute: 0)
          ),
          TravelRoute::Value::OpeningHour.NOT_OPEN]
      ),
      location: TravelRoute::Value::Location.new(latitude: 0, longitude: 0)
    )
    attractions = [a0, a1, a2, a3]
    a_count = attractions.size
    distance_calculator = TravelRoute::Entity::DistanceCalculator.new(attractions, Array.new(a_count, Array.new(a_count, TravelRoute::Value::Time.new(hour: 0, minute: 0))))
    day_durations = [
      [TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)],
      [TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)],
      [TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
    ]
    generated_plans = TravelRoute::Entity::Planner.new(attractions, distance_calculator)
      .generate_plans(day_durations, '2023/12/29', '2023/12/31')

    plan0 = [
      [['3', TravelRoute::Value::Time.new(hour: 9, minute: 0), TravelRoute::Value::Time.new(hour: 15, minute: 0)]],
      [
        ['0', TravelRoute::Value::Time.new(hour: 11, minute: 0), TravelRoute::Value::Time.new(hour: 14, minute: 0)],
        ['2', TravelRoute::Value::Time.new(hour: 14, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
      ],
      [['1', TravelRoute::Value::Time.new(hour: 13, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]]
    ]
    plan1 = [
      [['3', TravelRoute::Value::Time.new(hour: 9, minute: 0), TravelRoute::Value::Time.new(hour: 15, minute: 0)]],
      [['0', TravelRoute::Value::Time.new(hour: 11, minute: 0), TravelRoute::Value::Time.new(hour: 14, minute: 0)]],
      [
        ['2', TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 10, minute: 0)],
        ['1', TravelRoute::Value::Time.new(hour: 13, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]
      ]
    ]
    plan2 = [
      [['3', TravelRoute::Value::Time.new(hour: 9, minute: 0), TravelRoute::Value::Time.new(hour: 15, minute: 0)]],
      [
        ['2', TravelRoute::Value::Time.new(hour: 8, minute: 0), TravelRoute::Value::Time.new(hour: 10, minute: 0)],
        ['0', TravelRoute::Value::Time.new(hour: 11, minute: 0), TravelRoute::Value::Time.new(hour: 14, minute: 0)]
      ],
      [['1', TravelRoute::Value::Time.new(hour: 13, minute: 0), TravelRoute::Value::Time.new(hour: 16, minute: 0)]]
    ]

    _(generated_plans[0].to_list).must_equal(plan0)
    _(generated_plans[1].to_list).must_equal(plan1)
    _(generated_plans[2].to_list).must_equal(plan2)
  end
end
