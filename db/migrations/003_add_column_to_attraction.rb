# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :attractions, :description, String, null: true, default: nil
    add_column :attractions, :hour, Integer
    add_column :attractions, :minute, Integer
  end
end
