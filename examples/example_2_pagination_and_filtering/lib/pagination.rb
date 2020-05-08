class Pagination
  attr_reader :page, :limit, :search
  attr_accessor :count, :total

  DEFAULT_PAGE = 1
  DEFAULT_LIMIT = 20

  def initialize(page: DEFAULT_PAGE, limit: DEFAULT_LIMIT)
    @page = page
    @limit = limit
  end

  def offset
    (page - 1) * limit
  end

  def to_h
    {
      page: page,
      limit: limit,
      search: search,
      count: count,
      total: total
    }.compact
  end
end
