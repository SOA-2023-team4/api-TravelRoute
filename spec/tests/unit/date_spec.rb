# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

describe 'Unit test of Date value object' do
  it 'should return the correct day and index of a date' do
    dates = [
      '2023/12/24',
      '2023/12/25',
      '2023/12/26',
      '2023/12/27',
      '2023/12/28',
      '2023/12/29',
      '2023/12/30'
    ]
    correct = [
      ['Sunday', 0],
      ['Monday', 1],
      ['Tuesday', 2],
      ['Wednesday', 3],
      ['Thursday', 4],
      ['Friday', 5],
      ['Saturday', 6]
    ]
    dates.each_with_index do |date, index|
      day = TravelRoute::Value::Date.new(date)
      _(day.day_of_week).must_equal correct[index][0]
      _(day.day_of_week_index).must_equal correct[index][1]
    end
  end
  it 'should return the correct difference between two dates' do
    date1 = TravelRoute::Value::Date.new('2023/12/24')
    date2 = TravelRoute::Value::Date.new('2023/12/25')
    date3 = TravelRoute::Value::Date.new('2023/12/26')
    _(date2 - date1).must_equal 1
    _(date3 - date1).must_equal 2
  end
end
