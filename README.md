# Goodreads API wrapper

Ruby library to connect with Goodreads API.

[![Build Status](https://secure.travis-ci.org/sosedoff/goodreads.png)](http://travis-ci.org/sosedoff/goodreads)

## Installation

You can install this library via rubygems:

```
gem install goodreads
```

Or using rake:

```
rake install
```

## Getting Started

In order to use Goodreads API you must obtain an API key for your account.

Setup client:

```ruby
client = Goodreads::Client.new(:api_key => 'YOUR_KEY')

# or using a shortcut
client = Goodreads.new(:api_key => 'YOUR_KEY')
```

### Global configuration

Library allows you to define a global configuration options.

```ruby
Goodreads.configure(:api_key => 'YOUR_KEY')
```

Get current options:

```ruby
Goodreads.configuration # => {:api_key => 'YOUR_KEY'}
```

In case you need to reset options:

```ruby
Goodreads.reset_configuration
```

## Usage

### Lookup books

Find a book by ISBN:

```ruby
book = client.book_by_isbn('ISBN')
```
  
Find a book by Goodreads ID:

```ruby
book = client.book('id')
```
  
Find a book by title:

```ruby
book = client.book_by_title('Book title')
```
  
Search for books (by title, isbn, genre):

```ruby
search = client.search_books('Your search query')
search.results.work.each do |book|
  book.id        # => book ID
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
review.id         # => ID
review.user       # => User information
review.book       # => Book information
review.rating     # => User rating
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

## Contributions

Feel free to contribute any patches or new features.

Make sure to add a test coverage so it does not break any existing code.

For documentation please visit [API Reference](http://www.goodreads.com/api)

## License

Copyright &copy; 2011-2012 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.