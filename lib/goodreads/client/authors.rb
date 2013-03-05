module Goodreads
  module Authors
    # Get author details
    #
    def author(id, params={})
      params[:id] = id
      data = request('/author/show', params)
      Hashie::Mash.new(data['author'])
    end

    # Search for an author by name
    #
    def author_by_name(name, params={})
      params[:id] = name
      data = request('/api/author_url', params)
      Hashie::Mash.new(data['author'])
    end
  end
end
