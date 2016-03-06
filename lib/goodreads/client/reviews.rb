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
  end
end
