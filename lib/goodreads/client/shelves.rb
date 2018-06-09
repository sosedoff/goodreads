module Goodreads
  module Shelves
    # Get books from a user's shelf
    def shelf(user_id, shelf_name, options = {})
      options = options.merge(shelf: shelf_name, v: 2)
      data = request("/review/list/#{user_id}.xml", options)
      reviews = data["reviews"]["review"]

      books = []
      unless reviews.nil?
        # one-book results come back as a single hash
        reviews = [reviews] unless reviews.instance_of?(Array)
        books = reviews.map { |e| Hashie::Mash.new(e) }
      end

      Hashie::Mash.new(
        start: data["reviews"]["start"].to_i,
        end: data["reviews"]["end"].to_i,
        total: data["reviews"]["total"].to_i,
        books: books
      )
    end

    # Add book to a user's shelf
    #
    # Returns the user's review for the book, which includes all its current shelves
    def add_to_shelf(book_id, shelf_name, options = {})
      options = options.merge(book_id: book_id, name: shelf_name, v: 2)
      data = oauth_request_method(:post, "/shelf/add_to_shelf.xml", options)

      # when a book is on a single shelf it is a single hash
      shelves = data["my_review"]["shelves"]["shelf"]
      shelves = [shelves] unless shelves.instance_of?(Array)
      shelves = shelves.map do |s|
        Hashie::Mash.new({
          id:             s["id"].to_i,
          name:           s["name"],
          exclusive:      s["exclusive"] == "true",
          sortable:       s["sortable"] == "true",
        })
      end

      Hashie::Mash.new(
        id: data["my_review"]["id"].to_i,
        book_id: data["my_review"]["book_id"].to_i,

        rating: data["my_review"]["rating"].to_i,
        body: data["my_review"]["body"],
        body_raw: data["my_review"]["body_raw"],
        spoiler: data["my_review"]["spoiler_flag"] == "true",

        shelves: shelves,

        read_at: data["my_review"]["read_at"],
        started_at: data["my_review"]["started_at"],
        date_added: data["my_review"]["date_added"],
        updated_at: data["my_review"]["updated_at"],
      )
    end
  end
end
