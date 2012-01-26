require 'rest-client'
require 'active_support/core_ext'
require 'hashie'

module Goodreads
  module Request
    API_URL    = 'http://www.goodreads.com'
    API_FORMAT = 'xml'
    
    protected
    
    # Perform an API request
    #
    # path   - Request path
    # params - Parameters hash
    #
    def request(path, params={})
      if api_key.nil?
        raise Goodreads::ConfigurationError, 'API key required.'
      end
      
      params.merge!(:format => API_FORMAT, :key => api_key)
      url = "#{API_URL}#{path}"
      
      resp = RestClient.get(url, :params => params) do |response, request, result, &block|
        case response.code
          when 200
            response.return!(request, result, &block)
          when 401
            raise Goodreads::Unauthorized
          when 404
            raise Goodreads::NotFound
        end
      end
      
      hash = Hash.from_xml(resp)['GoodreadsResponse']
      hash.delete('Request')
      hash
    end
  end
end
