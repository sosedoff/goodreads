module Goodreads
  module Authors
    # Get author details
    #
    def author(id, params = {})
      params[:id] = id
      data = request("/author/show", params)
      Hashie::Mash.new(data["author"])
    end

    # Get an author's books
    #
    def author_books(id, params = {})
      params[:id] = id
      data = request("/author/list", params)
      Hashie::Mash.new(data["author"])
    end

    # Search for an author by name
    #
    def author_by_name(name, params = {})
      params[:id] = name
      name_encoded = URI.encode(name)
      data = request("/api/author_url/#{name_encoded}", params)
      Hashie::Mash.new(data["author"])
    end
  end
end
