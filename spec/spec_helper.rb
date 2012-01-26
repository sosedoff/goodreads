$:.unshift File.expand_path("../..", __FILE__)

require 'simplecov'
SimpleCov.start do
  add_group 'Goodreads', 'lib/goodreads'
end

require 'goodreads'
require 'webmock'
require 'webmock/rspec'

def stub_get(path, params, fixture_name)
  params[:format] = 'xml'
  stub_request(:get, api_url(path)).
    with(:query => params).
    to_return(
      :status => 200,
      :body => fixture(fixture_name)
    )
end

def stub_with_key_get(path, params, fixture_name)
  params[:key] = 'SECRET_KEY'
  stub_get(path, params, fixture_name)
end

def fixture_path(file=nil)
  path = File.expand_path("../fixtures", __FILE__)
  file.nil? ? path : File.join(path, file)
end

def fixture(file)
  File.read(fixture_path(file))
end

def api_url(path)
  "#{Goodreads::Request::API_URL}#{path}"
end
