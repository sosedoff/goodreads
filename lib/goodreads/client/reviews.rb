module Goodreads
  module Reviews
    # Recent reviews from all members.
    #
    # params[:skip_cropped] - Select only non-cropped reviews
    #
    def recent_reviews(params = {})
      skip_cropped = params.delete(:skip_cropped) || false
      data = request("/review/recent_reviews", params)
      return unless data["reviews"] && data["reviews"].key?("review")
      reviews = data["reviews"]["review"].map { |r| Hashie::Mash.new(r) }
      reviews = reviews.select { |r| !r.body.include?(r.url) } if skip_cropped
      reviews
    end

    # Get review details
    #
    def review(id)
      data = request("/review/show", id: id)
      Hashie::Mash.new(data["review"])
    end

    # Get list of reviews
    #
    def reviews(params = {})
      data = request("/review/list", params.merge(v: "2"))
      reviews = data["reviews"]["review"]
      if reviews.present?
        reviews.map { |review| Hashie::Mash.new(review) }
      else
        []
      end
    end

    # Get a user's review for a given book
    def user_review(user_id, book_id, params = {})
      data = request('/review/show_by_user_and_book.xml', params.merge(v: "2", user_id: user_id, book_id: book_id))
      Hashie::Mash.new(data["review"])
    end

    # Add review for a book
    #
    # Params can include :review, :rating, and :shelf
    #
    # review: text of the review (optional)
    # rating: rating (0-5) (optional, default is 0 (no rating))
    # shelf: Name of shelf to add book to (optional, must exist, see: shelves.list)
    #
    # Note that Goodreads API documentation says that this endpoint accepts
    # the read_at parameter but it does not appear to work as of 2018-06.
    def create_review(book_id, params = {})
      params = params.merge(book_id: book_id, v: "2")

      params[:read_at] = params[:read_at].strftime('%Y-%m-%d') if params[:read_at].is_a?(Time)

      params[:'review[review]'] = params.delete(:review) if params[:review]
      params[:'review[rating]'] = params.delete(:rating) if params[:rating]
      params[:'review[read_at]'] = params.delete(:read_at) if params[:read_at]

      data = oauth_request_method(:post, '/review.xml', params)

      Hashie::Mash.new(data["review"])
    end
  end
end
