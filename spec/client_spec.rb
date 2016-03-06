require "spec_helper"
require "oauth"

describe "Client" do
  let(:client)  { Goodreads::Client.new(api_key: "SECRET_KEY") }
  before(:each) { Goodreads.reset_configuration }

  describe "#new" do
    it "requires an argument" do
      expect { Goodreads::Client.new(nil) }
        .to raise_error(ArgumentError, "Options hash required.")
    end

    it "requires a hash argument" do
      expect { Goodreads::Client.new("foo") }
        .to raise_error(ArgumentError, "Options hash required.")
    end
  end

  describe "#book_by_isbn" do
    before { stub_with_key_get("/book/isbn", { isbn: "0307463745" }, "book.xml") }

    it "returns a book by isbn" do
      book = client.book_by_isbn("0307463745")

      expect(book).to respond_to :id
      expect(book).to respond_to :title
    end

    context "when book does not exist" do
      before do
        stub_request(:get, "http://www.goodreads.com/book/isbn?format=xml&isbn=123456789&key=SECRET_KEY")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { client.book_by_isbn("123456789") }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#search_books" do
    before { stub_with_key_get("/search/index", { q: "Rework" }, "search_books_by_name.xml") }

    it "returns book search results" do
      result = client.search_books("Rework")

      expect(result).to be_a(Hashie::Mash)
      expect(result).to respond_to(:query)
      expect(result).to respond_to(:total_results)
      expect(result).to respond_to(:results)
      expect(result.results).to respond_to(:work)
      expect(result.query).to eq("Rework")
      expect(result.results.work.size).to eq(3)
      expect(result.results.work.first.id).to eq(6_928_276)
    end
  end

  describe "#book" do
    before { stub_with_key_get("/book/show", { id: "6732019" }, "book.xml") }

    it "returns a book by goodreads id" do
      expect { client.book("6732019") }.not_to raise_error
    end
  end

  describe "#book_by_title" do
    before { stub_with_key_get("/book/title", { title: "Rework" }, "book.xml") }

    it "returns a book by title" do
      expect { client.book_by_title("Rework") }.not_to raise_error
    end
  end

  describe "#recent_reviews" do
    before { stub_with_key_get("/review/recent_reviews", {}, "recent_reviews.xml") }

    it "returns recent reviews" do
      reviews = client.recent_reviews

      expect(reviews).to be_an(Array)
      expect(reviews).to_not be_empty
      expect(reviews.first).to respond_to(:id)
    end

    context "with skip_cropped: true" do
      before { stub_with_key_get("/review/recent_reviews", {}, "recent_reviews.xml") }

      it "returns only full reviews" do
        reviews = client.recent_reviews(skip_cropped: true)
        expect(reviews).to be_an(Array)
        expect(reviews).to_not be_empty
      end
    end
  end

  describe "#review" do
    before { stub_with_key_get("/review/show", { id: "166204831" }, "review.xml") }

    it "returns review details" do
      review = client.review("166204831")

      expect(review).to be_a(Hashie::Mash)
      expect(review.id).to eq("166204831")
    end

    context "when review does not exist" do
      before do
        stub_request(:get, "http://www.goodreads.com/review/show?format=xml&id=12345&key=SECRET_KEY")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { client.review("12345") }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#reviews" do
    subject { client.reviews(id: user_id, shelf: shelf) }
    let(:user_id) { "5076380" }
    let(:shelf) { "to-read" }

    before { stub_with_key_get("/review/list", { v: "2", id: user_id, shelf: shelf }, response_fixture) }
    let(:response_fixture) { "reviews.xml" }

    it "returns a list of reviews" do
      expect(subject).to be_an(Array)
      expect(subject.count).to eq(2)
      expect(subject.first).to be_a(Hashie::Mash)
      expect(subject.first.keys).to include(*%w(book rating started_at read_at))
      expect(subject.map(&:id)).to eq(%w(1371624338 1371623371))
    end

    context "when there are no more reviews" do
      let(:response_fixture) { "reviews_empty.xml" }

      it "returns an empty array" do
        expect(subject).to be_an(Array)
        expect(subject.count).to eq(0)
      end
    end

    context "when user does not exist" do
      before do
        url_params = "v=2&format=xml&id=#{user_id}&key=SECRET_KEY&shelf=#{shelf}"
        stub_request(:get, "http://www.goodreads.com/review/list?#{url_params}")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { subject }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#author" do
    before { stub_with_key_get("/author/show", { id: "18541" }, "author.xml") }

    it "returns author details" do
      author = client.author("18541")

      expect(author).to be_a(Hashie::Mash)
      expect(author.id).to eq("18541")
      expect(author.name).to eq("Tim O'Reilly")
      expect(author.link).to eq("http://www.goodreads.com/author/show/18541.Tim_O_Reilly")
      expect(author.fans_count).to eq(109)
      expect(author.image_url).to eq("http://photo.goodreads.com/authors/1199698411p5/18541.jpg")
      expect(author.small_image_url).to eq("http://photo.goodreads.com/authors/1199698411p2/18541.jpg")
      expect(author.about).to eq("")
      expect(author.influences).to eq("")
      expect(author.works_count).to eq("34")
      expect(author.gender).to eq("male")
      expect(author.hometown).to eq("Cork")
      expect(author.born_at).to eq("1954/06/06")
      expect(author.died_at).to be_nil
    end

    context "when author does not exist" do
      before do
        stub_request(:get, "http://www.goodreads.com/author/show?format=xml&id=12345&key=SECRET_KEY")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { client.author("12345") }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#author_by_name" do
    before do
      stub_with_key_get("/api/author_url/Orson%20Scott%20Card", { id: "Orson Scott Card" }, "author_by_name.xml")
    end

    it "returns author details" do
      author = client.author_by_name("Orson Scott Card")

      expect(author).to be_a(Hashie::Mash)
      expect(author.id).to eq("589")
      expect(author.name).to eq("Orson Scott Card")
      expect(author.link).to eq("http://www.goodreads.com/author/show/589.Orson_Scott_Card?utm_medium=api&utm_source=author_link")
    end
  end

  describe "#user" do
    before { stub_with_key_get("/user/show", { id: "878044" }, "user.xml") }

    it "returns user details" do
      user = client.user("878044")

      expect(user).to be_a(Hashie::Mash)
      expect(user.id).to eq("878044")
      expect(user.name).to eq("Jan")
      expect(user.user_name).to eq("janmt")
    end

    context "when user does not exist" do
      before do
        stub_request(:get, "http://www.goodreads.com/user/show?format=xml&id=12345&key=SECRET_KEY")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { client.user("12345") }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#friends" do
    before do
      allow(client).to receive(:oauth_request)
        .and_return(Hash.from_xml(fixture("friends.xml"))["GoodreadsResponse"])
    end

    it "returns friend details" do
      friends = client.friends("878044")

      expect(friends).to be_an_instance_of(Hashie::Mash)
      expect(friends).to respond_to(:user)
      expect(friends.user.size).to eq(friends.end.to_i)
      expect(friends.user.first).to respond_to(:name)
    end
  end

  describe "#shelf" do
    it "returns list of books for a user's specified shelf" do
      stub_with_key_get("/review/list/1.xml", { shelf: "to-read", v: "2" }, "to-read.xml")

      shelf = client.shelf("1", "to-read")

      expect(shelf).to respond_to(:start)
      expect(shelf).to respond_to(:end)
      expect(shelf).to respond_to(:total)
      expect(shelf).to respond_to(:books)

      expect(shelf.start).to eq(1)
      expect(shelf.end).to eq(20)
      expect(shelf.total).to eq(40)
      expect(shelf.books.length).to eq(20)
      expect(shelf.books.first.id).to eq("45590939")
      expect(shelf.books.first.book.title.strip).to eq("The Demon-Haunted World: Science as a Candle in the Dark")
    end

    it "paginates book lists from a user's shelf" do
      stub_with_key_get("/review/list/1.xml", { shelf: "to-read", v: "2", page: "2" }, "to-read-p2.xml")

      shelf = client.shelf("1", "to-read", page: 2)

      expect(shelf.start).to eq(21)
      expect(shelf.end).to eq(40)
      expect(shelf.total).to eq(40)
      expect(shelf.books.length).to eq(20)
      expect(shelf.books.first.id).to eq("107804211")
      expect(shelf.books.first.book.title).to match(/Your Money or Your Life/)
    end

    it "returns an empty array when shelf is empty" do
      stub_with_key_get("/review/list/1.xml", { shelf: "to-read", v: "2" }, "empty.xml")

      shelf = client.shelf("1", "to-read")

      expect(shelf.start).to eq(0)
      expect(shelf.end).to eq(0)
      expect(shelf.total).to eq(0)
      expect(shelf.books.length).to eq(0)
    end
  end

  describe "#user_id" do
    let(:consumer) { OAuth::Consumer.new("API_KEY", "SECRET_KEY", site: "http://www.goodreads.com") }
    let(:token)    { OAuth::AccessToken.new(consumer, "ACCESS_TOKEN", "ACCESS_SECRET") }

    before do
      stub_request(:get, "http://www.goodreads.com/api/auth_user")
        .to_return(status: 200, body: fixture("oauth_response.xml"), headers: {})
    end

    it "returns id of the user with oauth authentication" do
      client = Goodreads::Client.new(api_key: "SECRET_KEY", oauth_token: token)
      expect(client.user_id).to eq("2003928")
    end
  end

  describe "#group" do
    before { stub_with_key_get("/group/show", { id: "1" }, "group.xml") }

    it "returns group details" do
      group = client.group("1")

      expect(group).to be_a(Hashie::Mash)
      expect(group.id).to eq("1")
      expect(group.title).to eq("Goodreads Feedback")
      expect(group.access).to eq("public")
      expect(group.location).to eq("")
      expect(group.category).to eq("Business")
      expect(group.subcategory).to eq("Companies")
      expect(group.group_users_count).to eq("10335")
    end
  end

  describe "#group_list" do
    before { stub_with_key_get("/group/list", { id: "1", sort: "my_activity" }, "group_list.xml") }

    it "returns groups a given user is a member of" do
      group_list = client.group_list("1")

      expect(group_list).to be_a(Hashie::Mash)
      expect(group_list.total).to eq("107")
      expect(group_list.group.count).to eq(50)
      expect(group_list.group[0].id).to eq("1")
      expect(group_list.group[0].title).to eq("Goodreads Feedback")
      expect(group_list.group[1].id).to eq("220")
      expect(group_list.group[2].users_count).to eq("530")
    end
  end
end
