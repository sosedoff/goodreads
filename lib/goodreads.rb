require 'goodreads/version'
require 'goodreads/errors'
require 'goodreads/request'
require 'goodreads/client'

module Goodreads
  class << self
    attr_accessor :options
  end
  self.options = {}

  # Create a new Goodreads::Client instance
  #
  def self.new(params = {})
    Goodreads::Client.new(params)
  end

  # Define a global configuration
  #
  # options[:api_key]    - Account API key
  # options[:api_secret] - Account API secret
  #
  def self.configure(params = {})
    fail(ArgumentError, 'Options hash required.') unless params.is_a?(Hash)

    options[:api_key]    = params[:api_key]
    options[:api_secret] = params[:api_secret]
    options
  end

  # Returns global configuration hash
  #
  def self.configuration
    options
  end

  # Resets the global configuration
  #
  def self.reset_configuration
    self.options = {}
  end
end
