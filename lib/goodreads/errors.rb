module Goodreads
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class Forbidden < Error; end
  class Unauthorized < Error; end
  class NotFound < Error; end
  class ServerError < Error; end
  class UnknownError < Error; end
end
