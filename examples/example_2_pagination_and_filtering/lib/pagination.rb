class Pagination
  attr_reader :limit, :offset
  attr_accessor :count, :total

  def initialize(limit: 20, offset: 0)
    @limit = limit
    @offset = offset
  end
end
