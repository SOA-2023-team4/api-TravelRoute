# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:attractions) do
      rename_column :opening_hours, :opening_hours_json
    end
  end
end
