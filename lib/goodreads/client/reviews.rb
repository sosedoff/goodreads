module Goodreads
  module Reviews
    # Recent reviews from all members.
    #
    # params[:skip_cropped] - Select only non-cropped reviews
    #
    def recent_reviews(params={})
      skip_cropped = params.delete(:skip_cropped) || false
      data = request('/review/recent_reviews', params)
      if data['reviews'] && data['reviews'].key?('review')
        reviews = data['reviews']['review'].map { |r| Hashie::Mash.new(r) }
        reviews = reviews.select { |r| !r.body.include?(r.url) } if skip_cropped
        reviews
      end
    end
    
    # Get review details
    #
    def review(id)
      data = request('/review/show', :id => id)
      Hashie::Mash.new(data['review'])
    end
  end
end
