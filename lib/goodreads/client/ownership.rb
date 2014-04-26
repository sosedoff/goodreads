module Goodreads
  module Ownership

    # Get list of owned books
    def owned_books(id)
      data = oauth_request('/owned_books/user', :id => id)
      owned_books = data['owned_books']['owned_book']

      books = []
      books = owned_books.map {|e| Hashie::Mash.new(e)} 
    end

    # Add ownership for a book
    def add_ownership(book_id)
      data = oauth_update('/owned_books.xml', {'owned_book[book_id]' => book_id})
    end

  end
end