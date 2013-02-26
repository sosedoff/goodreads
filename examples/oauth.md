# Authorizing Goodreads via OAuth

For services requiring permission, such as write operations or browsing friends, the client must be authorized through OAuth.

## Request Tokens vs. Access Tokens

First, get an OAuth *request* token:

```ruby
request_token = OAuth::Consumer.new(
  Goodreads.configuration[:api_key],
  Goodreads.configuration[:api_secret],
  :site => 'http://www.goodreads.com'
).get_request_token
```

Next, authorize by opening the authorization URL in a browser:

```ruby
request_token.authorize_url
```

Then request an OAuth *access* token:

```ruby
access_token = request_token.get_access_token
```

Finally, initialize a Goodreads client with it:

```ruby
goodreads_client = Goodreads.new :oauth_token => access_token
```

For more info, see the [Goodreads documentation](http://www.goodreads.com/api/oauth_example).

## User ID

Get the ID of the user who authorized via OAuth:

```ruby
goodreads_client.user_id
```

## Friends

Get the friend details for a user:

```ruby
friends_hash = goodreads_client.friends [user_id]
```

Get a list of their names:

```ruby
friends_hash.user.map{ |u| u.name }
```