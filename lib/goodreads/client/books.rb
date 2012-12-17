module Goodreads
  module Books
    # Search for books
    #
    # query   - Text to match against book title, author, and ISBN fields.
    # options - Optional search parameters
    #
    # options[:page] - Which page to returns (default: 1)
    # options[:field] - Search field. One of: title, author, or genre (default is all)
    #
    def search_books(query, params={})
      params[:q] = query.to_s.strip
      data = request('/search/index', params)
      Hashie::Mash.new(data['search'])
    end
    
    # Get book details by Goodreads book ID
    #
    def book(id)
      Hashie::Mash.new(request('/book/show', :id => id)['book'])
    end
    
    # Get book details by book ISBN
    #
    def book_by_isbn(isbn)
      Hashie::Mash.new(request('/book/isbn', :isbn => isbn)['book'])
    end
    
    # Get book details by book title
    #
    def book_by_title(title)
      Hashie::Mash.new(request('/book/title', :title => title)['book'])
    end
  end
end
