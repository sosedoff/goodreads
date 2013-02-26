# Goodreads [![Build Status](https://secure.travis-ci.org/ivanoblomov/goodreads.png)](http://travis-ci.org/ivanoblomov/goodreads)

Ruby wrapper to communicate with Goodreads API.

## Installation

Install gem with rubygems:

```
gem install goodreads
```

Or manually:

```
rake install
```

## Getting Started

Before using Goodreads API you must create a new application. Visit [signup form](http://www.goodreads.com/api/keys) for details.

Setup client:

``` ruby
client = Goodreads::Client.new(:api_key => 'KEY', :api_secret => 'SECRET')
client = Goodreads.new(:api_key => 'KEY') # short version
```

### Global configuration

You can define client credentials on global level. Just create an initializer file (if using rails) under
`config/initializers`:

``` ruby
Goodreads.configure(
  :api_key => 'KEY',
  :api_secret => 'SECRET'
)
```

Get global configuration:

``` ruby
Goodreads.configuration # => {:api_key => 'YOUR_KEY'}
```

In case you need to reset options:

```ruby
Goodreads.reset_configuration
```

## Usage

### Lookup books

You can lookup a book by ISBN, ID or Title:

```ruby
client.book('id')
client.book_by_isbn('ISBN')
client.book_by_title('Book title')
```

Search for books (by title, isbn, genre):

```ruby
search = client.search_books('The Lord Of The Rings')

search.results.work.each do |book|
  book.id        # => book id
  book.title     # => book title
end
```

### Reviews

Pull recent reviews:

```ruby
client.recent_reviews.each do |r|
  r.id            # => review id
  r.book.title    # => review book title
  r.body          # => review message
  r.user.name     # => review user name
end
```

Get review details:

```ruby
review = client.review('id')

review.id         # => review id
review.user       # => user information
review.book       # => uook information
review.rating     # => user rating
```

### Shelves

Get the books on a user's shelf:

```ruby
shelf = client.shelf(user_id, shelf_name)

shelf.books  # array of books on this shelf
shelf.start  # start index of this page of paginated results
shelf.end    # end index of this page of paginated results
shelf.total  # total number of books on this shelf
```

### Groups

Get group details:

```ruby
group = client.group('id')

group.id                 # => group id
group.title              # => group title
group.access             # => group's access settings
                         # => (e.g., public or private)
group.group_users_count  # => number of users in the group
```

List the groups a given user is a member of:

```ruby
group_list = client.group_list('user_id', 'sort')

group_list.total         # => total number of groups
group_list.group!.count  # => number of groups returned in the request

# Loop through the list to get details for each of the groups.

group_list.group.each do |g|
  g.id                 # => group id
  g.access             # => access settings (private, public)
  g.users_count        # => number of members
  g.title              # => title
  g.image_url          # => url of the group's image
  g.last_activity_at   # => date and time of the group's last activity
end
```

The `sort` parameter is optional, and defaults to `my_activity`. For other sorting options, [see here](http://www.goodreads.com/api#group.list).

### OAuth

For API calls requiring permission, such as write operations or browsing friends, see our [OAuth tutorial](examples/oauth.md).

## Testing

To run the test suite:

```
rake test
```

## Contributions

You're welcome to submit patches and new features.

- Create a new branch for your feature of bugfix
- Add tests so it does not break any existing code
- Open a new pull request
- Check official [API documentation](http://www.goodreads.com/api)

## License

Copyright &copy; 2011-2013 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
