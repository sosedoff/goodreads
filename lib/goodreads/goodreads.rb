module Goodreads
  API_URL = 'http://www.goodreads.com'
  API_FORMAT = 'xml'
  
  class AuthError < Exception ; end
  class NotFound < Exception ; end
  class GeneralError < Exception ; end
end