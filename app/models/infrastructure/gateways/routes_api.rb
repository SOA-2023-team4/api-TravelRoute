# frozen_string_literal: true

require 'http'

require_relative 'request'
require_relative 'response'

module TravelRoute
  module GoogleMaps
    module Routes
      # Routes Api
      class Api
        ROUTE_MATRIX_PATH = 'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix'
        ROUTE_PATH = 'https://routes.googleapis.com/directions/v2:computeRoutes'
        # options: DRIVE, BICYCLE, WALK, TWO_WHEELER, TRANSIT
        DEFAULT_TRAVEL_MODE = 'DRIVE'
        # options: # TRAFFIC_AWARE, TRAFFIC_UNAWARE, TRAFFIC_AWARE_OPTIMAL
        DEFAULT_ROUTING_OPTION = 'TRAFFIC_UNAWARE'

        def initialize(api_key)
          @key = api_key
        end

        def create_headers(fields)
          {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': @key,
            'X-Goog-FieldMask': fields.join(',')
          }
        end

        def route_data(origin, destination)
          fields = %w[routes.duration routes.distanceMeters routes.polyline.encodedPolyline]
          headers = create_headers(fields)
          body = {
            origin: { placeId: origin },
            destination: { placeId: destination },
            routingPreference: DEFAULT_ROUTING_OPTION,
            travelMode: DEFAULT_TRAVEL_MODE
          }
          Request.post(ROUTE_PATH, headers, body).parse
        end

        def route_matrix_data(places)
          fields = %w[originIndex destinationIndex duration distanceMeters status]
          headers = create_headers(fields)
          body = RouteMatrix.new(places).create_route_matrix_body
          Request.post(ROUTE_MATRIX_PATH, headers, body).parse
        end

        # Prepare route matrix request body
        class RouteMatrix
          def initialize(places)
            @places = places
          end

          def create_route_matrix_body
            {
              origins: waypoints,
              destinations: waypoints,
              routingPreference: DEFAULT_ROUTING_OPTION,
              travelMode: DEFAULT_TRAVEL_MODE
            }
          end

          private

          def waypoints
            @places.map { |place| { waypoint: { placeId: place.place_id } } }
          end
        end
      end
    end
  end
end
