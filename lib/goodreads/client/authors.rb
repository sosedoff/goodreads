module Goodreads
  module Authors
    # Get author details
    #
    def author(id, params={})
      params[:id] = id
      data = request('/author/show', params)
      Hashie::Mash.new(data['author'])
    end

    def author2(id, params={})
      params[:id] = id
      data = request('/api/author_url', params)
      Hashie::Mash.new(data['author'])
    end
  end
end
