require 'goodreads/version'
require 'goodreads/errors'
require 'goodreads/request'
require 'goodreads/client'

module Goodreads
  @@options = {}
  
  # Create a new Goodreads::Client instance
  #
  def self.new(options={})
    Goodreads::Client.new(options)
  end
  
  # Define a global configuration
  #
  # options[:api_key]    - Account API key
  # options[:api_secret] - Account API secret
  #
  def self.configure(options={})
    unless options.kind_of?(Hash)
      raise ArgumentError, "Options hash required."
    end
    
    @@options[:api_key]    = options[:api_key]
    @@options[:api_secret] = options[:api_secret]
    @@options
  end
  
  # Returns global configuration hash
  #
  def self.configuration
    @@options
  end
  
  # Resets the global configuration
  #
  def self.reset_configuration
    @@options = {}
  end
end
