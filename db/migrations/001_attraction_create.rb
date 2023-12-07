# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:attractions) do
      primary_key :id

      String      :place_id, unique: true, null: false
      String      :name, null: false
      String      :address
      Float       :rating
      Float       :longitude
      Float       :latitude
      String      :type, null: true, default: nil
      jsonb       :opening_hours, null: true, default: nil

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
