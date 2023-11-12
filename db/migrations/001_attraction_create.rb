# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:attraction) do
      primary_key :id

      String      :place_id, unique: true, null: false
      String      :name, unique: true, null: false
      String      :address
      Float       :rating

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
