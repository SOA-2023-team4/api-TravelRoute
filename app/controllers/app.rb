# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

# The core class of the web app for TravelRoute
module TravelRoute
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, path: 'app/presentation/assets', group_subdirs: false,
                    css: 'style.css',
                    js: {
                      home: ['home.js'],
                      plan: ['plan.js']
                    }
    plugin :common_logger, $stderr

    # use Rack::MethodOverride

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      # GET /
      routing.root do
        session[:cart] ||= []
        session[:saved] ||= {}
        cart_map = session[:cart].map do |place_id|
          Repository::Attractions.find_id(place_id)
        end
        cart = Views::AttractionList.new(cart_map)
        view 'home', locals: { cart: cart.attractions }
      end

      routing.on 'search' do
        # POST /search
        routing.is do
          routing.post do
            req = JSON.parse(routing.body.read, symbolize_names: true)
            raise Views::Attraction::InvalidSearchTerm if req[:search_term].empty?

            search_term = req[:search_term]
            searched_attraction = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find(search_term)
            Views::AttractionList.new(searched_attraction).to_json
          rescue Views::Attraction::InvalidSearchTerm
            flash[:error] = 'Search term cannot be empty'
            routing.halt 400
          rescue StandardError => e
            App.logger.error e.backtrace.join("\n")
            flash[:error] = 'Something went wrong'
            routing.halt 500
          end
        end
      end

      routing.on 'attractions' do
        routing.is do
          # POST /attractions
          routing.post do
            req = JSON.parse(routing.body.read)
            selected = JSON.parse(req['selected'], symbolize_names: true)
            selected_attraction = Entity::Attraction.new(selected)
            Repository::Attractions.update_or_create(selected_attraction)
            session[:cart].push(selected_attraction.place_id).uniq!
            Views::Attraction.new(selected_attraction).to_json
          end

          # DELETE /attractions
          routing.delete do
            req = JSON.parse(routing.body.read, symbolize_names: true)
            removed = req[:removed]
            removed == 'all' ? session[:cart].clear : session[:cart].delete(removed)
            { removed: }.to_json
          end
        rescue StandardError => e
          App.logger.error e.backtrace.join("\n")
          flash[:error] = 'Something went wrong'
          routing.halt 500
        end
      end

      routing.on 'adjustment' do
        routing.is do
          # GET /adjustment
          routing.get do
            cart = session[:cart].map do |place_id|
              Repository::Attractions.find_id(place_id) ||
                Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
            end
            view 'adjustment', locals: { cart: }
          end
        rescue StandardError => e
          App.logger.error e.backtrace.join("\n")
          flash[:error] = 'Something went wrong'
          routing.redirect '/plans'
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

            places = place_ids.map do |place_id|
              Repository::Attractions.find_id(place_id) ||
                Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
            end
            guidebook = Mapper::GuidebookMapper.new(App.config.GMAP_TOKEN).generate_guidebook(places)
            origin = Repository::Attractions.find_id(origin_id)
            plan_entity = Entity::Planner.new(guidebook).generate_plan(origin)
            plan = Views::Plan.new(plan_entity)
            session[:temp_plan] = plan
            view 'plan', locals: { plan: }
          end

          # POST /plans
          routing.post do
            plan = session[:temp_plan].plan
            plan_name = routing.params['plan_name']
            saved = plan_name.empty? ? Views::Plan.new(plan) : Views::Plan.new(plan, plan_name)
            session[:saved].merge!(saved.name => saved)
            flash[:notice] = 'Plan saved'
            routing.redirect "/plans?origin=#{saved.origin.place_id}"
          end

          # DELETE /plans
          routing.delete do
            req = JSON.parse(routing.body.read, symbolize_names: true)
            deleted = req[:plan_name]
            session[:saved].delete(deleted)
            { success: true }.to_json
          end
        rescue StandardError => e
          App.logger.error e.backtrace.join("\n")
          flash[:error] = 'Something went wrong'
          routing.redirect '/plans'
        end
      end
    end
  end
end
