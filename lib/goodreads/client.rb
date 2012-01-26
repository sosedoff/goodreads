require 'goodreads/client'
require 'goodreads/client/books'
require 'goodreads/client/reviews'
require 'goodreads/client/authors'
require 'goodreads/client/users'

module Goodreads
  class Client
    include Goodreads::Request
    include Goodreads::Books
    include Goodreads::Reviews
    include Goodreads::Authors
    include Goodreads::Users
    
    attr_reader :api_key, :api_secret
    
    # Initialize a Goodreads::Client instance
    #
    # options[:api_key]    - Account API key
    # options[:api_secret] - Account API secret
    #
    def initialize(options={})
      unless options.kind_of?(Hash)
        raise ArgumentError, "Options hash required."
      end
      
      @api_key    = options[:api_key]
      @api_secret = options[:api_secret]
    end
  end
end