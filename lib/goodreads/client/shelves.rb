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
    
    # List all shelves of a user
    def user_shelves(user_id, options:  {})
      options = options.merge(user_id: user_id)
      data = request("/shelf/list.xml", options)

      shelves = data["shelves"]["user_shelf"].map do |s|
        Hashie::Mash.new({
          id:          s["id"],
          name:        s["name"],
          book_count:  s["book_count"],
          exclusive:   s["exclusive_flag"],
          description: s["description"]
        })
      end

      Hashie::Mash.new(
        start:   data["shelves"]["start"].to_i,
        end:     data["shelves"]["end"].to_i,
        total:   data["shelves"]["total"].to_i,
        shelves: shelves 
      )
    end
  end
end
