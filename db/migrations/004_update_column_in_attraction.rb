# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    remove_column :attractions, :stay_time
    add_column :attractions, :hour, Integer
    add_column :attractions, :minute, Integer
  end
end
