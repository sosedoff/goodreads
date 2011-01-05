module Goodreads
  class Client
    @@config = {}
    
    # Initialize the API client
    # You must specify the API key given by goodreads in order to make requests
    # :api_key - Your api key
    def initialize(opts={})
      raise ArgumentError, 'API key required!' unless opts.key?(:api_key)
      @@config[:api_key] = opts[:api_key]
    end
    
    # Get most recent reviews
    # :skip_cropped - Select only non-cropped reviews
    def recent_reviews(params={})
      data = request('/review/recent_reviews', params)
      reviews = data['reviews']['review'].collect { |r| Goodreads::Record.new(r) }
      reviews = reviews.select { |r| !r.body.include?(r.url) } if params.key?(:skip_cropped)
      return reviews
    end
    
    # Get book (including reviews) by ISBN.
    # :skip_cropped_reviews - Select only non-cropped book reviews
    # :page - Reviews page
    # :per_page - Reviews per page (default to 30)
    def book_by_isbn(isbn, params={})
      params.merge!(:isbn => isbn)
      data = request('/book/isbn', params)
      record = Goodreads::Record.new(data['book'])
      if params.key?(:skip_cropped_reviews)
        record.reviews['review'] = record.reviews.review.select { |r| !r.body.include?(r.url) }
      end
      return record
    end
    
    private
    
    # Perform an API request
    def request(path, params={})
      params.merge!(:format => 'xml', :key => @@config[:api_key])
      begin
        resp = RestClient.get("#{API_URL}#{path}", :params => params)
        Hash.from_xml(resp)['GoodreadsResponse']
      rescue RestClient::Unauthorized
        raise AuthError, 'Invalid API token!'
      rescue Exception => ex
        raise NotFound, 'Resource was not found!' if ex.http_code == 404
        raise GeneralError, ex.message
      end
    end
  end
end