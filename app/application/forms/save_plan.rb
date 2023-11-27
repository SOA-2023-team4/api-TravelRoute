# frozen_string_literal: true

require 'dry-validation'

module TravelRoute
  module Forms
    # Form validation for selected attraction
    class SavePlan < Dry::Validation::Contract
      params do
        optional(:plan_name).maybe(:string)
      end
    end
  end
end
