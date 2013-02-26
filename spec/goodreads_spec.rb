require 'spec_helper'

describe 'Goodreads' do
  describe '.new' do
    it 'returns a new client instance' do
      Goodreads.new.should be_a Goodreads::Client
    end
  end

  describe '.configure' do
    it 'sets a global configuration options' do
      r = Goodreads.configure(:api_key => 'FOO', :api_secret => 'BAR')
      r.should be_a Hash
      r.should have_key(:api_key)
      r.should have_key(:api_secret)
      r[:api_key].should eql('FOO')
      r[:api_secret].should eql('BAR')
    end

    it 'raises ConfigurationError on invalid config parameter' do
      proc { Goodreads.configure(nil) }.
        should raise_error(ArgumentError, "Options hash required.")

      proc { Goodreads.configure('foo') }.
        should raise_error ArgumentError, "Options hash required."
    end
  end

  describe '.configuration' do
    before do
      Goodreads.configure(:api_key => 'FOO', :api_secret => 'BAR')
    end

    it 'returns global configuration options' do
      r = Goodreads.configuration
      r.should be_a Hash
      r.should have_key(:api_key)
      r.should have_key(:api_secret)
      r[:api_key].should eql('FOO')
      r[:api_secret].should eql('BAR')
    end
  end

  describe '.reset_configuration' do
    before do
      Goodreads.configure(:api_key => 'FOO', :api_secret => 'BAR')
    end

    it 'resets global configuration options' do
      Goodreads.reset_configuration
      Goodreads.configuration.should eql({})
    end
  end
end
