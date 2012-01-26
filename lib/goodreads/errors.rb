module Goodreads
  class Error              < StandardError; end
  class ConfigurationError < Error ; end
  class Unauthorized       < Error ; end
  class NotFound           < Error ; end
end
