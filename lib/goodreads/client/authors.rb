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

    # Get an author's list of books by author id
    #
    def books_by_author(id, params={})
      params[:id] = id
      data = request('/author/list', params)
      book_list = data['author']['books']['book']

      books = []
      books = book_list.map {|b| Hashie::Mash.new(b)}

      Hashie::Mash.new({
        :start => data['author']['books']['start'].to_i,
        :end => data['author']['books']['end'].to_i,
        :total => data['author']['books']['total'].to_i,
        :books => books
      }) 
    end

    # Get the list of series for an author
    #
    def series_by_author(id)
      data = request('/series/list', {:id => id})
      series_list = data['series_works']

      series = []
      series = series_list.map {|s| Hashie::Mash.new(s)}
    end

  end
end
