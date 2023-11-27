# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :attractions, :opening_hours, :jsonb, null: true, default: nil
    add_column :attractions, :type, String, null: true, default: nil
  end
end
