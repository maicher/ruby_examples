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

    if validation.failure?
      # Render 422 here:
      return { status: 422, description: 'Invalid pagination params', content: validation.errors }

      # or redirect omitting the invalid params:
      # redirect_to action: :index, **without_invalid_params(validation)
    end

    # handle the request
    #
    { status: 200, content: {} }
  end

  private

  attr_reader :params

  def without_invalid_params(validation)
    validation.to_h.except(*validation.errors.to_h.keys)
  end
end
