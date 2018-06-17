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

  describe "#oauth_configured?" do
    it "is true when OAuth token provided to constructor" do
      client = Goodreads::Client.new(oauth_token: "a token")
      expect(client.oauth_configured?).to be true
    end

    it "is true when oauth token is not provided to constructor" do
      client = Goodreads::Client.new(api_key: "SECRET_KEY")
      expect(client.oauth_configured?).to be false
    end
  end

  describe "#request" do
    it "makes an OAuth request if client has an oauth_token" do
      oauth_token = double
      response = double
      allow(oauth_token).to receive(:request)
        .and_return(response)
      allow(response).to receive(:body)
        .and_return(fixture("book.xml"))

      client = Goodreads::Client.new(oauth_token: oauth_token)
      client.book(123)
    end

    it "makes an HTTP request with token if client does have an oauth_token" do
      allow(client).to receive(:http_request)
        .and_return(Hash.from_xml(fixture("book.xml"))["GoodreadsResponse"])
      client.book(123)
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
        stub_request(:get, "https://www.goodreads.com/book/isbn?format=xml&isbn=123456789&key=SECRET_KEY")
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
        stub_request(:get, "https://www.goodreads.com/review/show?format=xml&id=12345&key=SECRET_KEY")
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
        stub_request(:get, "https://www.goodreads.com/review/list?#{url_params}")
          .to_return(status: 404, body: "", headers: {})
      end

      it "raises Goodreads::NotFound" do
        expect { subject }.to raise_error(Goodreads::NotFound)
      end
    end
  end

  describe "#user_review" do
    let(:consumer) { OAuth::Consumer.new("API_KEY", "SECRET_KEY", site: "https://www.goodreads.com") }
    let(:token)    { OAuth::AccessToken.new(consumer, "ACCESS_TOKEN", "ACCESS_SECRET") }

    it "returns a user's existing review" do
      stub_request(:get, "https://www.goodreads.com/review/show_by_user_and_book.xml?book_id=50&user_id=1&v=2")
        .to_return(status: 200, body: fixture("review_show_by_user_and_book.xml"))

      client = Goodreads::Client.new(api_key: "SECRET_KEY", oauth_token: token)
      review = client.user_review(1, 50)

      expect(review.id).to eq("21")
      expect(review.book.id).to eq(50)

      expect(review.rating).to eq("5")
      expect(review.body.strip).to eq("")
      expect(review.date_added).to eq("Tue Aug 29 11:20:01 -0700 2006")
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
        stub_request(:get, "https://www.goodreads.com/author/show?format=xml&id=12345&key=SECRET_KEY")
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
        stub_request(:get, "https://www.goodreads.com/user/show?format=xml&id=12345&key=SECRET_KEY")
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

  describe "#add_to_shelf" do
    let(:consumer) { OAuth::Consumer.new("API_KEY", "SECRET_KEY", site: "https://www.goodreads.com") }
    let(:token)    { OAuth::AccessToken.new(consumer, "ACCESS_TOKEN", "ACCESS_SECRET") }

    it "adds a book to a user's shelf" do
      stub_request(:post, "https://www.goodreads.com/shelf/add_to_shelf.xml")
        .with(:body => {"book_id"=>"456", "name"=>"read", "v"=>"2"})
        .to_return(status: 201, body: fixture("shelf_add_to_shelf.xml"))

      client = Goodreads::Client.new(api_key: "SECRET_KEY", oauth_token: token)
      review = client.add_to_shelf(456, "read")

      expect(review.id).to eq(2416981504)
      expect(review.book_id).to eq(456)

      expect(review.rating).to eq(0)
      expect(review.body).to be nil
      expect(review.body_raw).to be nil
      expect(review.spoiler).to be false

      expect(review.shelves.size).to eq(1)
      expect(review.shelves.first.name).to eq("read")
      expect(review.shelves.first.id).to eq(269274694)
      expect(review.shelves.first.exclusive).to be true
      expect(review.shelves.first.sortable).to be false


      expect(review.read_at).to be nil
      expect(review.started_at).to be nil
      expect(review.date_added).to eq("Thu Jun 07 19:58:19 -0700 2018")
      expect(review.updated_at).to eq("Thu Jun 07 19:58:53 -0700 2018")

      expect(review.body).to be nil
      expect(review.body_raw).to be nil
      expect(review.spoiler).to be false
    end
  end

  describe "#create_review" do
    let(:consumer) { OAuth::Consumer.new("API_KEY", "SECRET_KEY", site: "https://www.goodreads.com") }
    let(:token)    { OAuth::AccessToken.new(consumer, "ACCESS_TOKEN", "ACCESS_SECRET") }

    it "creates a new review for a book" do
      stub_request(:post, "https://www.goodreads.com/review.xml")
        .with(:body => {
          "book_id"=>"456",
          "review" => {
            "rating" => "3",
            "review" => "Good book.",
            "read_at" => "2018-01-02",
          },
          "shelf" => "read",
          "v"=>"2",
        })
        .to_return(status: 201, body: fixture("review_create.xml"))

      client = Goodreads::Client.new(api_key: "SECRET_KEY", oauth_token: token)
      review = client.create_review(456, {
        :review => "Good book.",
        :rating => 3,
        :read_at => Time.parse('2018-01-02'),
        :shelf => "read",
      })

      expect(review.id).to eq("67890")
      expect(review.book.id).to eq(456)
      expect(review.rating).to eq("3")
      expect(review.body).to eq("Good book.")
    end
  end

  describe "#user_id" do
    let(:consumer) { OAuth::Consumer.new("API_KEY", "SECRET_KEY", site: "https://www.goodreads.com") }
    let(:token)    { OAuth::AccessToken.new(consumer, "ACCESS_TOKEN", "ACCESS_SECRET") }

    before do
      stub_request(:get, "https://www.goodreads.com/api/auth_user")
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
