require 'goodreads/version'
require 'goodreads/errors'
require 'goodreads/request'
require 'goodreads/client'

module Goodreads
  # Create a new Goodreads::Client instance
  #
  def self.new(options={})
    Goodreads::Client.new(options)
  end
end
