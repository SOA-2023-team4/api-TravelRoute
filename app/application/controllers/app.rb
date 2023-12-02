# frozen_string_literal: true

require 'roda'

# The core class of the web app for TravelRoute
module TravelRoute
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
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
            lookup_result = Service::LookupAttraction.new.call(place_id:)

            if lookup_result.failure?
              failed = Representer::HttpResponse.new(lookup_result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(lookup_result.value!)
            response.status = http_response.http_status_code
            Representer::Attraction.new(lookup_result.value!.message).to_json
          end

          routing.is do
            # GET /attractions?search=
            routing.get do
              search = Request::AttractionSearch.new(routing.params)
              search_result = Service::SearchAttractions.new.call(search)

              if search_result.failure?
                failed = Representer::HttpResponse.new(search_result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(search_result.value!)
              response.status = http_response.http_status_code
              Representer::AttractionsList.new(search_result.value!.message).to_json
            end

            # POST /attractions
            routing.post do
              body = Request::Attraction.new(routing.body.read)
              add_result = Service::AddAttraction.new.call(body)

              if add_result.failure?
                flash[:error] = add_result.failure
                routing.halt 400
              end

              http_response = Representer::HttpResponse.new(add_result.value!)
              response.status = http_response.http_status_code
              Representer::Attraction.new(add_result.value!.message).to_json
            end
          end
        end
      end

      routing.on 'plans' do
        # GET /plans/:plan_name
        routing.on String do |plan_name|
          routing.get do
            plan = session[:saved][plan_name]
            view 'plan', locals: { plan: }
          end
        end

        routing.is do
          # GET /plans
          routing.get do
            origin_id = routing.params['origin']
            place_ids = session[:cart]
            plan_req = Service::GeneratePlan.new.call(cart: place_ids, origin: origin_id)

            if plan_req.failure?
              flash[:error] = plan_req.failure
              routing.redirect "/plans?origin=#{origin_id}"
            end

            plan = Views::Plan.new(plan_req.value!)
            session[:temp_plan] = plan
            view 'plan', locals: { plan: }
          end

          # POST /plans
          # routing.post do
          #   plan = session[:temp_plan].plan
          #   save_req = Forms::SavePlan.new.call(routing.params)

          #   if save_req.failure?
          #     flash[:error] = save_req.errors.messages.join('; ')
          #     routing.redirect '/plans'
          #   end

          #   plan_name = save_req[:plan_name]
          #   saved = plan_name.nil? ? Views::Plan.new(plan) : Views::Plan.new(plan, plan_name)
          #   session[:saved].merge!(saved.name => saved)
          #   flash[:notice] = 'Plan saved'
          #   routing.redirect "/plans?origin=#{saved.origin.place_id}"
          # end

          # DELETE /plans
          # routing.delete do
          #   req = JSON.parse(routing.body.read, symbolize_names: true)
          #   del_req = Forms::DeletePlan.new.call(req)

          #   if del_req.failure?
          #     flash[:error] = del_req.errors.messages.join('; ')
          #     routing.redirect '/plans'
          #   end

          #   deleted = del_req[:plan_name]
          #   session[:saved].delete(deleted)
          #   { success: true }.to_json
          # end
        end
      end
    end
  end
end
