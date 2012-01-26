require 'spec_helper'

describe 'Client' do
  it 'raises exception if API key was not provided' do
    client = Goodreads::Client.new
    
    proc { client.book_by_isbn('0307463745') }.
      should raise_error Goodreads::ConfigurationError, 'API key required.'
  end
    
  it 'should raise Goodreads::Unauthorized if API key is not valid' do
    client = Goodreads::Client.new(:api_key => 'INVALID_KEY')
    
    stub_request(:get, "http://www.goodreads.com/book/isbn?format=xml&isbn=054748250711&key=INVALID_KEY").
      to_return(:status => 401)
      
    proc { client.book_by_isbn('054748250711') }.
      should raise_error Goodreads::Unauthorized
  end
end
