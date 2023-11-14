# frozen_string_literal: true

require 'roda'
require 'slim'

# The core class of the web app for TravelRoute
module TravelRoute
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :assets, path: 'app/presentation/assets', group_subdirs: false,
                    js: {
                      home: ['home.js'],
                      plan: ['plan.js']
                    }
    plugin :common_logger, $stderr

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      # GET /
      routing.root do
        session[:cart] ||= []
        search_term = routing.params.key?('search-term') ? routing.params['search-term'] : ''
        attractions = search_term.empty? ? [] : Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find(search_term)
        cart = session[:cart].map do |place_id|
          Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
        end
        view 'home', locals: { attractions: , cart: }
      end

      routing.on 'select-attraction' do
        routing.is do
          routing.post do
            selected = routing.params.key?('selected') ? routing.params['selected'] : ''
            session[:cart].append(selected)
            routing.redirect '/'
          end
        end
      end

      routing.on 'remove-attraction' do
        routing.is do
          routing.post do
            selected = routing.params.key?('selected') ? routing.params['selected'] : ''
            session[:cart].delete(selected)
            routing.redirect '/'
          end
        end
      end

      routing.on 'adjustment' do
        routing.is do
          routing.get do
            cart = session[:cart].map do |place_id|
              Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
            end
            view 'adjustment', locals: { cart: }
          end
        end
      end

      routing.on 'plan' do
        routing.is do
          routing.get do
            origin_id = routing.params['origin']
            place_ids = session[:cart]

            places = place_ids.map do |place_id|
              Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(place_id)
            end
            guidebook = Mapper::GuidebookMapper.new(App.config.GMAP_TOKEN).generate_guidebook(places)
            origin = Mapper::AttractionMapper.new(App.config.GMAP_TOKEN).find_by_id(origin_id)
            plan = Entity::Planner.new(guidebook).generate_plan(origin)
            view 'plan', locals: {plan: Views::Plan.new(plan)}
          end
        end
      end
    end
  end
end
