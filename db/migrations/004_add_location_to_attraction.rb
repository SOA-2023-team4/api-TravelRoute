# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :attractions, :latitude, Float
    add_column :attractions, :longitude, Float
  end
end
