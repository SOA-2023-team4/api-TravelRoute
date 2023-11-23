# frozen_string_literal: true

require 'dry-validation'

module TravelRoute
  module Forms
    # Form validation for selected attraction
    class DeletePlan < Dry::Validation::Contract
      params do
        required(:plan_name).filled(:string)
      end
    end
  end
end
