# frozen_string_literal: true

require 'roda'

# The core class of the web app for TravelRoute
module TravelRoute
  # Web App
  class App < Roda
    plugin :halt
    plugin :all_verbs

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "ShowDaPlan API v1 is running at /api/v1 in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'attractions' do
          # GET /attractions/:place_id
          routing.on String do |place_id|
            add_result = Service::AddAttraction.new.call(place_id:)

            if add_result.failure?
              failed = Representer::HttpResponse.new(add_result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(add_result.value!)
            response.status = http_response.http_status_code
            Representer::Attraction.new(add_result.value!.message).to_json
          end

          routing.is do
            # GET /attractions?search=
            routing.get do
              search_req = Request::AttractionSearch.new(routing.params)
              search_result = Service::SearchAttractions.new.call(search_req:)

              if search_result.failure?
                failed = Representer::HttpResponse.new(search_result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(search_result.value!)
              response.status = http_response.http_status_code
              Representer::AttractionsList.new(search_result.value!.message).to_json
            end
          end
        end

        routing.on 'recommendations' do
          routing.get do
            routing.on String do |place_id|
              result = Service::RecommendAttractions.new.call(place_id:)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::AttractionsList.new(result.value!.message).to_json
            end
          end
        end
        routing.on 'plans' do
          routing.get do
            origin_index = routing.params['origin']
            place_ids = routing.params['attractions']
            result = Service::GeneratePlan.new.call(place_ids:, origin_index:)
            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end
            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::Plan.new(result.value!.message).to_json
          end
        end
      end
    end
  end
end
