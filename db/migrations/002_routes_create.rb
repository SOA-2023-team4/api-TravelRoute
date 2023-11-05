# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:routes) do
      primary_key :id
      foreign_key :origin_id, :places
      foreign_key :destination_id, :places
      check { origin_id != destination_id }

      Integer :distance_meters
      Integer :duration

      index %i[origin_id destination_id]
    end
  end
end
