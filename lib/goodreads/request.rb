require "active_support/core_ext/hash"
require "rest-client"
require "hashie"

module Goodreads
  module Request
    API_URL    = "http://www.goodreads.com"
    API_FORMAT = "xml"

    protected

    # Perform an API request
    #
    # path   - Request path
    # params - Parameters hash
    #
    def request(path, params = {})
      token = api_key || Goodreads.configuration[:api_key]

      fail(Goodreads::ConfigurationError, "API key required.") if token.nil?

      params.merge!(format: API_FORMAT, key: token)
      url = "#{API_URL}#{path}"

      resp = RestClient.get(url, params: params) do |response, request, result, &block|
        case response.code
        when 200
          response.return!(request, result, &block)
        when 401
          fail(Goodreads::Unauthorized)
        when 403
          fail(Goodreads::Forbidden)
        when 404
          fail(Goodreads::NotFound)
        end
      end

      parse(resp)
    end

    # Perform an OAuth API request. Goodreads must have been initialized with a valid OAuth access token.
    #
    # path   - Request path
    # params - Parameters hash
    #
    def oauth_request(path, params = nil)
      fail "OAuth access token required!" unless @oauth_token
      if params
        url_params = params.map { |k, v| "#{k}=#{v}" }.join("&")
        path = "#{path}?#{url_params}"
      end
      resp = @oauth_token.get(path, "Accept" => "application/xml")

      case resp
      when Net::HTTPUnauthorized
        fail Goodreads::Unauthorized
      when Net::HTTPNotFound
        fail Goodreads::NotFound
      end

      parse(resp)
    end

    def parse(resp)
      hash = Hash.from_xml(resp.body)["GoodreadsResponse"]
      hash.delete("Request")
      hash
    end
  end
end
