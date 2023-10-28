# frozen_string_literal: true

require 'roda'
require 'yaml'

module TravelRoute
  # Configuration for the App
  class App < Roda
    require 'pry'

    CONFIG = YAML.safe_load_file('config/secrets.yml')
    GMAP_TOKEN = CONFIG['MAPS_API_KEY']
  end
end
