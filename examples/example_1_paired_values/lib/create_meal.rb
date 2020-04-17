# frozen_string_literal: true

require 'dry-validation'
require 'dry/transaction'
require 'meal'

class CreateMeal
  include Dry::Transaction

  class Contract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
      required(:proteins).filled(Nutrient.schema)
      required(:fiber).filled(Nutrient.schema)
    end
  end

  step :validate_params
  step :persist_meal

  def validate_params(params:)
    validation = Contract.new.call(params)
    if validation.success?
      Success(validation: validation)
    else
      Failure(description: 'Invalid params', validation: validation)
    end
  end

  def persist_meal(validation:)
    meal = Meal.new
    meal.name = validation[:name]
    meal.proteins = Nutrient.new(validation[:proteins])
    meal.fiber = Nutrient.new(validation[:fiber])
    # meal.save!

    Success(meal: meal)
  end
end
