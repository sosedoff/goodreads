module Goodreads
  module Shelves

    # Get books from a user's shelf
    def shelf(user_id, shelf_name, options={})
      options = options.merge(:shelf => shelf_name, :v =>2)
      data = request("/review/list/#{user_id}.xml", options)
      reviews = data['reviews']['review']

      books = []
      unless reviews.nil?
        # one-book results come back as a single hash
        reviews = [reviews] if !reviews.instance_of?(Array) 
        books = reviews.map {|e| Hashie::Mash.new(e)} 
      end

      Hashie::Mash.new({
        :start => data['reviews']['start'].to_i,
        :end => data['reviews']['end'].to_i,
        :total => data['reviews']['total'].to_i,
        :books => books
      })
    end

    # Get list of shelf names
    def list_shelf_names(id)
      list_shelves(id).names
    end

    # Get list of shelves
    def list_shelves(id)
      data = request('/shelf/list.xml', {:user_id => id})
      shelf_list = data['shelves']['user_shelf']

      shelves = []
      shelves = shelf_list.map {|s| Hashie::Mash.new(s)} 

      names = []
      names = shelves.map {|s| s.name}

      Hashie::Mash.new({
        :start => data['shelves']['start'].to_i,
        :end => data['shelves']['end'].to_i,
        :total => data['shelves']['total'].to_i,
        :shelves => shelves,
        :names => names
      })
    end

    # Add book to shelf
    def add_book_to_shelf(book_id, shelf)
      data = oauth_update('/shelf/add_book_to_shelf.xml', 
        {:book_id => book_id, :name => shelf})
    end

    # Add books to multiple shelves
    def add_books_to_shelves(book_ids, shelves)
      data = oauth_update('/shelf/add_books_to_shelves.xml', 
        {:bookids => book_ids, :shelves => shelves})
    end

    # Remove book from shelf
    def remove_book_from_shelf(book_id, shelf)
      data = oauth_update('/shelf/add_book_to_shelf.xml', 
        {:book_id => book_id, :name => shelf, :a => 'remove'})
    end

  end
end
