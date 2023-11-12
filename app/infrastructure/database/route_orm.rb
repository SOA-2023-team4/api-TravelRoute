# frozen_string_literal: true

require 'sequel'

module TravelRoute
  module Database
    # Object-Relational Mapper for Routes
    class RouteOrm < Sequel::Model(:routes)
      many_to_one :origin,
                  class: :'TravelRoute::Database::AttractionOrm'

      many_to_one :destination,
                  class: :'TravelRoute::Database::AttractionOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
