# Kartograph

A Serialization / Deserialization library.

[![Build Status](https://travis-ci.org/digitalocean/kartograph.svg?branch=master)](https://travis-ci.org/digitalocean/kartograph)

## Installation

Add this line to your application's Gemfile:

    gem 'kartograph'

And then execute:

    $ bundle

## Usage

Kartograph makes it easy to generate and convert JSON. It's intention is to be used for API clients.

For example, if you have an object that you would like to convert to JSON for a create request to an API. You would have something similar to this:

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    mapping User # The object we're mapping

    property :name, :email, scopes: [:create, :update]
    property :id, scopes: :read
  end
end

user = User.new(name: 'Bobby Tables')
json_for_create = UserMapping.representation_for(:create, user)
```

### Rendering Objects or Collections as Hashes

```ruby
user = User.new(name: 'PB Jelly')
users = [user]

hash = UserMapping.hash_for(:read, user)
hash_collection = UserMapping.hash_collection_for(:read, user)
```

### Rendering Collections as JSON

```ruby
user = User.new(name: 'Bobby Tables')
users = Array.new(10, user)

json = UserMapping.represent_collection_for(:read, users)
```

---

Some API's will give you the created resource back as JSON as well on a successful create. For that, you may do something like this:

```ruby
response = HTTPClient.post("http://something.com/api/users", body: json_for_create)
created_user = UserMapping.extract_single(response.body, :read)
```

Most API's will have a way of retrieving an entire resource collection. For this you can instruct Kartograph to convert a collection.

```ruby
response = HTTPClient.get("http://something.com/api/users")
users = UserMapping.extract_collection(response.body, :read)
# => [ User, User, User ]
```

### Getting Harder

Sometimes resources will nest other properties under a key. Kartograph can handle this as well.

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    mapping User # The object we're mapping

    property :name, scopes: [:read]

    property :comments do
      mapping Comment # The nested object we're mapping

      property :text, scopes: [:read]
      property :author, scopes: [:read]
    end
  end
end
```

Just like the previous examples, when you serialize this. It will include the comment block for the scope defined.

### Root Keys

Kartograph can also handle the event of root keys in response bodies. For example, if you receive a response with:

```json
{ "user": { "id": 123 } }
```

You could define a mapping like this:


```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    mapping User
    root_key singular: 'user', plural: 'users', scopes: [:read]
    property :id, scopes: [:read]
  end
end
```

This means that when you call the same thing:

```ruby
response = HTTPClient.get("http://something.com/api/users")
users = UserMapping.extract_collection(response.body, :read)
```

It will look for the root key before trying to deserialize the JSON response.
The advantage of this is it will only use the root key if there is a scope defined for it.


### Including other definitions within eachother

Sometimes you might have models that are nested within eachother on responses. Or you simply want to cleanup definitions by separating concerns. Kartograph lets you do this with includes.

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    mapping User
    property :id, scopes: [:read]
    property :comments, plural: true, include: CommentMapping
  end
end

class CommentMapping
  include Kartograph::DSL

  kartograph do
    mapping Comment
    property :id, scopes: [:read]
    property :text, scopes: [:read]
  end
end
```


### Scope blocks

Sometimes adding scopes to all properties can be tedious, to avoid that, you can define properties within a scope block.

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    scoped :read do
      property :name
      property :id
      property :email, key: 'email_address' # The JSON returned has the key of email_address, our property is called email however.
    end

    scoped :update, :create do
      property :name
      property :email, key: 'email_address'
    end
  end
end
```

Now when JSON includes comments for a user, it will know how to map the comments using the provided Kartograph definition.

---

### Caching

Kartograph has the option to cache certain serializations, determined by the way you setup the key.

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    cache { Rails.cache } # As long as this respond to #fetch(key_name, options = {}, &block) it will work
    cache_key { |object| object.cache_key }

    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/digitaloceancloud/kartograph/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
