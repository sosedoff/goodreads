require "spec_helper"

describe Goodreads::Client do
  before :each do
    Goodreads.reset_configuration
  end

  let(:client) do
    described_class.new(api_key: api_key)
  end

  context "API key is missing" do
    let(:api_key) {}

    it "throws an error" do
      expect { client.book_by_isbn("0307463745") }
        .to raise_error(Goodreads::ConfigurationError, "API key required.")
    end
  end

  context "API key is invalid" do
    let(:api_key) { "INVALID_KEY" }

    before do
      stub_request(:get, "https://www.goodreads.com/book/isbn?format=xml&isbn=1&key=INVALID_KEY")
        .to_return(status: 401)

      stub_request(:get, "https://www.goodreads.com/book/isbn?format=xml&isbn=2&key=INVALID_KEY")
        .to_return(status: 403)
    end

    it "throws errors" do
      expect { client.book_by_isbn("1") }.to raise_error(Goodreads::Unauthorized)
      expect { client.book_by_isbn("2") }.to raise_error(Goodreads::Forbidden)
    end
  end
end
