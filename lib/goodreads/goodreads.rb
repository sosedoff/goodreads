module Goodreads
  API_URL = 'http://www.goodreads.com'
  API_FORMAT = 'xml'
  
  class Error < StandardError; end
  class Unauthorized < Error ; end
  class NotFound < Error ; end

end
