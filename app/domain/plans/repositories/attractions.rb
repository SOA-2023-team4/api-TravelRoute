# frozen_string_literal: true

# attribute :place_id,  Strict::String
# attribute :name,      Strict::String
# attribute :address,   Strict::String
# attribute :rating,    Coercible::Float

module TravelRoute
  module Repository
    # Repository for Place Entities
    class Attractions
      def self.all
        Database::AttractionOrm.all.map { |db_place| rebuild_entity(db_place) }
      end

      def self.find(entity)
        find_id(entity.place_id)
      end

      def self.find_id(place_id)
        db_record = Database::AttractionOrm.first(place_id:)
        rebuild_entity(db_record)
      end

      def self.find_name(place_name)
        db_records = Database::AttractionOrm.where(Sequel.ilike(:name, "%#{place_name}%"))
        rebuild_many(db_records)
      end

      def self.find_or_create(entity)
        Database::AttractionOrm.find_or_create(entity.to_attr_hash)
      end

      def self.update_or_create(entity)
        return update(entity) if find(entity)

        create(entity)
      end

      def self.update(entity)
        db_row = Database::AttractionOrm.first(place_id: entity.place_id)
        return find(entity) unless update?(entity)

        db_row.update(entity.to_attr_hash)
        rebuild_entity(db_row)
      end

      def self.update?(entity)
        db_row = find(entity)
        db_row != entity
      end

      def self.create(entity)
        raise 'Place already exists' if find(entity)

        db_place = Database::AttractionOrm.find_or_create(entity.to_attr_hash)
        rebuild_entity(db_place)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        entry = reformat_hash(db_record.to_hash)
        Entity::Attraction.new(entry)
      end

      # might want to refactor this in the database in the future
      def self.reformat_hash(db_record_hash)
        opening_hours = db_record_hash[:opening_hours].values
          .map { |day| Value::OpeningHour.new(day) }
          .then { |days| Value::OpeningHours.new(opening_hours: days) }

        location = Value::Location.new(db_record_hash[:location])
        stay_time = Value::Time.new(db_record_hash[:stay_time])
        db_record_hash.merge({ opening_hours:, location:, stay_time:})
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_record|
          rebuild_entity(db_record)
        end
      end
    end
  end
end
