require "spec_helper"

describe "Client" do
  before :each do
    Goodreads.reset_configuration
  end

  it "raises Goodreads::ConfigurationError if API key was not provided" do
    client = Goodreads::Client.new

    expect { client.book_by_isbn("0307463745") }
      .to raise_error(Goodreads::ConfigurationError, "API key required.")
  end

  it "raises Goodreads::Unauthorized if API key is not valid" do
    client = Goodreads::Client.new(api_key: "INVALID_KEY")

    stub_request(:get, "https://www.goodreads.com/book/isbn?format=xml&isbn=054748250711&key=INVALID_KEY")
      .to_return(status: 401)

    expect { client.book_by_isbn("054748250711") }
      .to raise_error(Goodreads::Unauthorized)
  end
end
