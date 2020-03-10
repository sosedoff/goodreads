module Goodreads
  module Series
    # See all items in a series
    def series(series_id)
      Hashie::Mash.new(request("/series/show/#{series_id}")['series'])
    end

    # See all series for an author
    def series_by_author(author_id)
      res = request("/series/list", {id: author_id})['series_works']
      return Hashie::Mash.new if res.blank?

      Hashie::Mash.new(res)
    end

    # See all series a work is in
    def series_by_work(work_id)
      res = request("/series/work/#{work_id}")['series_works']
      return Hashie::Mash.new if res.blank?

      Hashie::Mash.new(res)
    end
  end
end