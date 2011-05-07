module Goodreads
  API_URL = 'http://www.goodreads.com'
  API_FORMAT = 'xml'
  
  class Error < StandardError; end
  class Unauthorized < Error ; end
  class NotFound < Error ; end
  
  def self.configure(api_key)
    Goodreads::Client.configure({:api_key => api_key})  
  end
end