module GoodReads
  class Record
    def initialize(data=nil)
      @fields = {}
      setup(data) unless data.nil?
    end
    
    def setup(data)
      data.each_pair do |key, value|
        case value
          when Hash
            @fields[key] = Record.new(value)
          when NilClass
            @fields[key] = nil
          when Array
            @fields[key] = value.collect { |v| Record.new(v) }
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