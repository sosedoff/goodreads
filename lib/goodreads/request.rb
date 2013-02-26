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
      token = api_key || Goodreads.configuration[:api_key]

      if token.nil?
        raise Goodreads::ConfigurationError, 'API key required.'
      end

      params.merge!(:format => API_FORMAT, :key => token)
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

      parse(resp)
    end

    # Perform an OAuth API request. Goodreads must have been initialized with a valid OAuth access token.
    #
    # path   - Request path
    # params - Parameters hash
    #
    def oauth_request(path, params=nil)
      raise 'OAuth access token required!' unless @oauth_token
      path = "#{path}?#{params.map{|k,v|"#{k}=#{v}"}.join('&')}" if params
      resp = @oauth_token.get(path, {'Accept'=>'application/xml'})

      case resp
        when Net::HTTPUnauthorized
          raise Goodreads::Unauthorized
        when Net::HTTPNotFound
          raise Goodreads::NotFound
      end

      parse(resp)
    end

    def parse(resp)
      hash = Hash.from_xml(resp.body)['GoodreadsResponse']
      hash.delete('Request')
      hash
    end
  end
end
