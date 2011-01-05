module GoodReads
  class Client
    @@config = {}
    
    def initialize(opts={})
      raise ArgumentError, 'API key required!' unless opts.key?(:api_key)
      @@config[:api_key] = opts[:api_key]
    end
    
    # Get most recent reviews
    def recent_reviews(params={})
      data = request('/review/recent_reviews', params)
      data['reviews']['review'].collect { |r| GoodReads::Record.new(r) }
    end
    
    # Get book (including reviews) by ISBN.
    def book_by_isbn(isbn, params={})
      params.merge!(:isbn => isbn)
      data = request('/book/isbn', params)
      GoodReads::Record.new(data['book'])
    end
    
    private
    
    def request(path, params={})
      url = "#{API_URL}#{path}"
      params.merge!(:format => 'xml', :key => @@config[:api_key])
      begin
        resp = RestClient.get(url, :params => params)
        XmlSimple.xml_in(resp, {'ForceArray' => false})
      rescue RestClient::Unauthorized
        raise AuthError, 'Invalid API token!'
      rescue Exception => ex
        raise GeneralError, ex.inspect
      end
    end
  end
end