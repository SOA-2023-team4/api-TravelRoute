# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    TravelRoute::App.db.run('PRAGMA foreign_keys = OFF')
    TravelRoute::Database::PlaceOrm.map(&:destroy)
    TravelRoute::Database::RouteOrm.map(&:destroy)
    TravelRoute::App.db.run('PRAGMA foreign_keys = ON')
  end
end
