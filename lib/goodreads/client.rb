require 'goodreads/client'
require 'goodreads/client/books'
require 'goodreads/client/reviews'
require 'goodreads/client/authors'
require 'goodreads/client/users'
require 'goodreads/client/shelves'
require 'goodreads/client/authorized'
require 'goodreads/client/groups'
require 'goodreads/client/friends'

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

    attr_reader :api_key, :api_secret, :oauth_token

    # Initialize a Goodreads::Client instance
    #
    # options[:api_key]     - Account API key
    # options[:api_secret]  - Account API secret
    # options[:oauth_token] - OAuth access token (optional, required for some calls)
    #
    def initialize(options={})
      unless options.kind_of?(Hash)
        raise ArgumentError, "Options hash required."
      end

      @api_key    = options[:api_key] || Goodreads.configuration[:api_key]
      @api_secret = options[:api_secret] || Goodreads.configuration[:api_secret]
      @oauth_token = options[:oauth_token]
    end
  end
end
