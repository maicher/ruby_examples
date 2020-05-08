require 'dry-validation'
require 'dry/transaction'

require 'pagination'

class Controller
  class Contract < Dry::Validation::Contract
    params do
      optional(:page).value(:integer).filled(gteq?: 1)
      optional(:limit).value(:integer).filled(:int?, included_in?: [10, 20, 50, 100])
      optional(:search).value(:string).filled(min_size?: 3)
    end
  end

  class User
    def self.limit(*); new; end
    def offset(*); self; end
    def where(*); self; end
    def load; []; end
    def count; 10; end
  end

  def initialize(params)
    @params = params
  end

  def index
    validation = Contract.new.call(params)

    if validation.success?
      @pagination = Pagination.new(**validation.to_h)
    else
      # Render 422 here:
      return { status: 422, description: 'Invalid pagination params', content: validation.errors }

      # or redirect omitting the invalid params:
      # redirect_to action: :index, **without_invalid_params(validation)
    end

    # Assuming that User is an AR model.
    query = User.limit(@pagination.limit).offset(@pagination.offset)
    query = query.where(username: @pagination.search) if @pagination.search
    @users = query.load

    # Pagination object doesn't need to make any operations on the results.
    # Set what's necessary - in this case: +count+ and +total+ - keeping the pagination separated from the results.
    @pagination.total = query.count
    @pagination.count = @users.count

    { status: 200, content: {}, pagination: @pagination.to_h }
    # or render view with pagination buttons based on the @pagination object
  end

  private

  attr_reader :params

  def without_invalid_params(validation)
    validation.to_h.except(*validation.errors.to_h.keys)
  end
end
