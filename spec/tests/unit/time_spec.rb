# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

describe 'Unit test of Time' do
  it 'minus and equal operator should work' do
    t1 = TravelRoute::Value::Time.new(hour: 10, minute: 0)
    t2 = TravelRoute::Value::Time.new(hour: 8, minute: 0)
    t3 = TravelRoute::Value::Time.new(hour: 2, minute: 0)
    _(t1 - t2).must_equal t3
  end
  it 'minus and equal operator should work' do
    t1 = TravelRoute::Value::Time.new(hour: 10, minute: 0)
    t2 = TravelRoute::Value::Time.new(hour: 8, minute: 0)
    _(t1 > t2).must_equal true
    _(t1 < t2).must_equal false
  end
end
