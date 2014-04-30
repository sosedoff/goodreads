module Goodreads
  module Ownership

    # Get list of owned books
    #
    # Get goodreads book id: client.owned_books(user_id)[i].book.id
    # Get book title: client.owned_books(user_id)[i].book.title
    # Get book author: client.owned_books(user_id)[i].book.authors.author.name
    # Get book owned?: client.owned_books(user_id)[i].review.owned
    # Get shelf of book: client.owned_books(user_id)[i].review.shelves.shelf.name
    # Get ISBN13: client.owned_books(user_id)[i].book.isbn13
    # Get number of pages: client.owned_books(user_id)[i].book.num_pages
    def owned_books(id, params={})
      params[:id] = id
      data = oauth_request('/owned_books/user', params)
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