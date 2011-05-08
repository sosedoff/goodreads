module Goodreads
  class Client
    @@config = {}
    
    # Initialize the API client
    # You must specify the API key given by goodreads in order to make requests
    #   :api_key - Your api key
    def self.configure(opts={})
      key = opts[:api_key].to_s
      raise ArgumentError, 'API key required!' if key.empty?
      @@config[:api_key] = opts[:api_key]
    end
    
    # Search for books
    # q => The query text to match against book title, author, and ISBN fields.
    # params => Optional search parameters
    #   :page => Which page to return (default 1, optional)
    #   :field => Field to search, one of title, author, or genre (default is all)
    def search_books(q, params={})
      params[:q] = q.to_s.strip
      data = request('/search/index', params)
      Hashie::Mash.new(data['search'])
    end
    
    # Get book details by Goodreads book ID
    def book(id)
      Hashie::Mash.new(request('/book/show', :id => id)['book'])
    end
    
    # Get book details by book ISBN
    def book_by_isbn(isbn)
      Hashie::Mash.new(request('/book/isbn', :isbn => isbn)['book'])
    end
    
    # Get book details by book title
    def book_by_title(title)
      Hashie::Mash.new(request('/book/title', :title => title)['book'])
    end
    
    # Recent reviews from all members.
    #   :skip_cropped - Select only non-cropped reviews
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
    def review(id)
      data = request('/review/show', :id => id)
      Hashie::Mash.new(data['review'])
    end
    
    # Get author details
    def author(id, params={})
      params[:id] = id
      data = request('/author/show', params)
      Hashie::Mash.new(data['author'])
    end
    
    # Get user details
    def user(id)
      data = request('/user/show', :id => id)
      Hashie::Mash.new(data['user'])
    end
    
    private
    
    # Perform an API request
    def request(path, params={})
      raise 'API key required!' unless @@config.key?(:api_key)
      params.merge!(:format => 'xml', :key => @@config[:api_key])
      
      resp = RestClient.get("#{API_URL}#{path}", :params => params) { |response, request, result, &block|
        case response.code
          when 200
            response.return!(request, result, &block)
          when 401
            raise Goodreads::Unauthorized
          when 404
            raise Goodreads::NotFound
        end
      }
      
      hash = Hash.from_xml(resp)['GoodreadsResponse']
      hash.delete('Request')
      hash
    end
  end
end