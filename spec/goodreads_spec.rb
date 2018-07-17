require "spec_helper"

describe Goodreads do
  describe ".new" do
    it "returns a new client instance" do
      expect(Goodreads.new).to be_a(Goodreads::Client)
    end
  end

  describe ".configure" do
    it "sets a global configuration options" do
      config = Goodreads.configure(api_key: "FOO", api_secret: "BAR")
      expect(config).to be_a(Hash)
      expect(config).to have_key(:api_key)
      expect(config).to have_key(:api_secret)
      expect(config[:api_key]).to eql("FOO")
      expect(config[:api_secret]).to eql("BAR")
    end

    it "raises ConfigurationError on invalid config parameter" do
      expect { Goodreads.configure(nil) }
        .to raise_error(ArgumentError, "Options hash required.")

      expect { Goodreads.configure("foo") }
        .to raise_error(ArgumentError, "Options hash required.")
    end
  end

  describe ".configuration" do
    before do
      Goodreads.configure(api_key: "FOO", api_secret: "BAR")
    end

    it "returns global configuration options" do
      config = Goodreads.configuration
      expect(config).to be_a(Hash)
      expect(config).to have_key(:api_key)
      expect(config).to have_key(:api_secret)
      expect(config[:api_key]).to eql("FOO")
      expect(config[:api_secret]).to eql("BAR")
    end
  end

  describe ".reset_configuration" do
    before do
      Goodreads.configure(api_key: "FOO", api_secret: "BAR")
    end

    it "resets global configuration options" do
      Goodreads.reset_configuration
      expect(Goodreads.configuration).to eql({})
    end
  end
end
