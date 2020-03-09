module Goodreads
  module Works
    # See all series a work is in
    def series(work_id)
      res = request("/series/work/#{work_id}")["series_works"]
      return Hashie::Mash.new if res.blank?

      Hashie::Mash.new(res)
    end
  end
end