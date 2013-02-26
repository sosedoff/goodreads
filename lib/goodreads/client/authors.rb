module Goodreads
  module Authors
    # Get author details
    #
    def author(id, params={})
      params[:id] = id
      data = request('/author/show', params)
      Hashie::Mash.new(data['author'])
    end

    # Get ID number of author
    #
    def authorID(id, params={})
      params[:id] = id
      data = request('/api/author_url', params)
      Hashie::Mash.new(data['author'])
    end

    # Get list of books by author
    #
    def authorList(id, params={})
      params[:id] = id
      data = request('/author/list', params)
      Hashie::Mash.new(data['author'])
    end
  end
end
