# frozen_string_literal: true

require 'dry-validation'

module TravelRoute
  module Forms
    # Form validation for selected attraction
    class SearchAttraction < Dry::Validation::Contract
      params do
        required(:search_term).filled(:string)
      end

      rules do
        key.failure('Search term should not be empty.') if value[:search_term].empty?
      end
    end
  end
end
