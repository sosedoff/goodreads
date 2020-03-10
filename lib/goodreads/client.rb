require "goodreads/client"
require "goodreads/client/books"
require "goodreads/client/reviews"
require "goodreads/client/authors"
require "goodreads/client/users"
require "goodreads/client/shelves"
require "goodreads/client/authorized"
require "goodreads/client/groups"
require "goodreads/client/friends"
require "goodreads/client/series"

module Goodreads
  class Client
    include Goodreads::Request
    include Goodreads::Books
    include Goodreads::Reviews
    include Goodreads::Authors
    include Goodreads::Users
    include Goodreads::Shelves
    include Goodreads::Authorized
    include Goodreads::Groups
    include Goodreads::Friends
    include Goodreads::Series

    attr_reader :api_key, :api_secret, :oauth_token

    # Initialize a Goodreads::Client instance
    #
    # options[:api_key]     - Account API key
    # options[:api_secret]  - Account API secret
    # options[:oauth_token] - OAuth access token (optional, required for some calls)
    #
    def initialize(options = {})
      fail(ArgumentError, "Options hash required.") unless options.is_a?(Hash)

      @api_key     = options[:api_key] || Goodreads.configuration[:api_key]
      @api_secret  = options[:api_secret] || Goodreads.configuration[:api_secret]
      @oauth_token = options[:oauth_token]
    end

    # Return if this client is configured with OAuth credentials
    # for a single user
    #
    # False when client is instantiated with an api_key and secret,
    # true when client is instantiated with an oauth_token
    def oauth_configured?
      !oauth_token.nil?
    end
  end
end
