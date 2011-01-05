module Goodreads
  class Record
    # Initialize the record and set its data if present
    def initialize(data=nil)
      @fields = {}
      setup(data) unless data.nil?
    end
    
    # Set or override the existing field value
    def []=(key, value)
      @fields[key] = value
    end
    
    # Get the field value by hash key
    def [](key)
      @fields[key]
    end
    
    # Load data into the record
    def setup(data)
      data.each_pair do |key, value|
        case value
          when Hash
            @fields[key] = Record.new(value)
          when Array
            @fields[key] = value.collect { |v| Record.new(v) }
          when NilClass
            @fields[key] = nil
          else
            @fields[key] = value
        end
        (class << self; self; end).class_eval do
          define_method(key.to_sym) { return @fields[key] }
        end
      end
    end
  end
end