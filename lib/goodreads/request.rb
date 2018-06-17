require "active_support/core_ext/hash"
require "rest-client"
require "hashie"

module Goodreads
  module Request
    API_URL    = "https://www.goodreads.com"
    API_FORMAT = "xml"

    protected

    # Perform an API request using API key or OAuth token
    #
    # path   - Request path
    # params - Parameters hash
    #
    # Will make a request with the configured API key (application
    # authentication) or OAuth token (user authentication) if available.
    def request(path, params = {})
      if oauth_configured?
        oauth_request(path, params)
      else
        http_request(path, params)
      end
    end

    # Perform an API request using API key
    #
    # path   - Request path
    # params - Parameters hash
    def http_request(path, params)
      token = api_key || Goodreads.configuration[:api_key]

      fail(Goodreads::ConfigurationError, "API key required.") if token.nil?

      params.merge!(format: API_FORMAT, key: token)
      url = "#{API_URL}#{path}"

      resp = RestClient.get(url, params: params) do |response, request, result, &block|
        case response.code
        when 200
          response.return!(&block)
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

    # Perform an OAuth API GET request. Goodreads must have been initialized with a valid OAuth access token.
    #
    # path   - Request path
    # params - Parameters hash
    #
    def oauth_request(path, params = {})
      oauth_request_method(:get, path, params)
    end

    # Perform an OAuth API request. Goodreads must have been initialized with a valid OAuth access token.
    #
    # http_method - HTTP verb supported by OAuth gem (one of :get, :post, :delete, etc.)
    # path   - Request path
    # params - Parameters hash
    #
    def oauth_request_method(http_method, path, params = {})
      fail "OAuth access token required!" unless @oauth_token

      headers = { "Accept" => "application/xml" }

      resp = if http_method == :get || http_method == :delete
        if params
          url_params = params.map { |k, v| "#{k}=#{v}" }.join("&")
          path = "#{path}?#{url_params}"
        end
        @oauth_token.request(http_method, path, headers)
      else
        @oauth_token.request(http_method, path, params || {}, headers)
      end

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
