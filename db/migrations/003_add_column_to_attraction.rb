# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :attractions, :description, String, null: true, default: nil
    add_column :attractions, :stay_time, Integer, null: true, default: nil
  end
end
