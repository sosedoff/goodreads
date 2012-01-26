require 'spec_helper'

describe 'Goodreads' do
  context '.new' do
    it 'returns a new client instance' do
      Goodreads.new.should be_a Goodreads::Client
    end
  end
end
