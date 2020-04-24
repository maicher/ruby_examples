require 'dry-validation'
require 'dry/transaction'

require 'pagination'

class Controller
  class Contract < Dry::Validation::Contract
    params do
      optional(:page).value(:integer).filled(gt?: 0)
      optional(:limit).value(:integer).filled(:int?, included_in?: [10, 20, 50, 100])
      optional(:search).value(:string).filled(min_size?: 3)
    end
  end

  def initialize(params)
    @params = params
  end

  def index
    validation = Contract.new.call(params)
    binding.pry

    if validation.failure?
      # render_unprocessable_entity(validation.errors)
      # or
      # redirect_to action: :index
      # or
      # redirect_to action: :index, **without_invalid_params(validation)
      #
      # return
    end

    # handle the request
  end

  private

  attr_reader :params

  def without_invalid_params(validation)
    validation.to_h.except(*validation.errors.to_h.keys)
  end

  def render_unprocessable_entity(description: 'Invalid input', content: nil)
    render json: {}.merge(description: description, content: content).compact, status: :unprocessable_entity
  end
end
