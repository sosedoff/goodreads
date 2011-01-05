require 'rubygems'
require 'rest-client'
require 'xmlsimple'

module GoodReads
  API_URL = 'http://www.goodreads.com'
  API_FORMAT = 'xml'
  
  class AuthError < Exception ; end
  class GeneralError < Exception ; end
end

require 'client'
require 'record'
require 'request'