# Goodreads [![Build Status](https://img.shields.io/travis/sosedoff/goodreads/master.svg)](http://travis-ci.org/sosedoff/goodreads)

Ruby wrapper to communicate with Goodreads API.

**NOTE: The Goodreads API [is being discontinued](https://www.goodreads.com/api).**

## Requirements

- Ruby 1.9.3+

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
client = Goodreads::Client.new(api_key: "KEY", api_secret: "SECRET")
client = Goodreads.new(api_key: "KEY") # short version
```

### Global configuration

You can define client credentials on global level. Just create an initializer file (if using rails) under
`config/initializers`:

``` ruby
Goodreads.configure(
  api_key: "KEY",
  api_secret: "SECRET"
)
```

Get global configuration:

``` ruby
Goodreads.configuration # => { api_key: "YOUR_KEY" }
```

In case you need to reset options:

```ruby
Goodreads.reset_configuration
```

## Examples

### Lookup books

You can lookup a book by ISBN, ID or Title:

```ruby
client.book("id")
client.book_by_isbn("ISBN")
client.book_by_title("Book title")
```

Search for books (by title, isbn, genre):

```ruby
search = client.search_books("The Lord Of The Rings")

search.results.work.each do |book|
  book.id        # => book id
  book.title     # => book title
end
```

### Authors

Look up an author by their Goodreads Author ID:

```ruby
author = client.author("id")

author.id              # => author id
author.name            # => author's name
author.link            # => link to author's Goodreads page
author.fans_count      # => number of fans author has on Goodreads
author.image_url       # => link to image of the author
author.small_image_url # => link to smaller of the author
author.about           # => description of the author
author.influences      # => list of links to author's influences
author.works_count     # => number of works by the author in Goodreads
author.gender          # => author's gender
author.hometown        # => author's hometown
author.born_at         # => author's birthdate
author.died_at         # => date of author's death
```

Look up an author by name:

```ruby
author = client.author_by_name("Author Name")

author.id     # => author id
author.name   # => author name
author.link   # => link to author's Goodreads page
```

Look up books by an author:

```ruby
author = client.author_Book("id")

author.id     # => author id
author.name   # => author name
author.link   # => link to author's Goodreads page
author.books  # => array of books by this author
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
review = client.review("id")

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
group = client.group("id")

group.id                 # => group id
group.title              # => group title
group.access             # => group's access settings
                         # => (e.g., public or private)
group.group_users_count  # => number of users in the group
```

List the groups a given user is a member of:

```ruby
group_list = client.group_list("user_id", "sort")

group_list.total         # => total number of groups
group_list.group.count  # => number of groups returned in the request

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

The `sort` parameter is optional, and defaults to `my_activity`.
For other sorting options, [see here](http://www.goodreads.com/api#group.list).

### Pagination

To retrieve results for a particular page use the `page` param when making calls:

```ruby
books = client.search_books("Term", page: 2)
```

### OAuth

For API calls requiring permission, such as write operations or browsing friends,
see our [OAuth tutorial](examples/oauth.md).

## Testing

To run the test suite:

```
bundle exec rake test
```

## Contributions

You're welcome to submit patches and new features.

- Create a new branch for your feature of bugfix
- Add tests so it does not break any existing code
- Open a new pull request
- Check official [API documentation](http://www.goodreads.com/api)

## License

The MIT License (MIT)
