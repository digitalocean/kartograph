# Kartograph

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'kartograph'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kartograph

## Usage

Kartograph makes it easy to generate and convert JSON. It's intention is to be used for API clients.

For example, if you have an object that you would like to convert to JSON for a create request to an API. You would have something similar to this:

```ruby
class UserMapping
  include Kartograph::DSL

  kartograph do
    property :name, scope: [:create, :update]
    property :id, scope: [:read]
  end
end

user = User.new(name: 'Bobby Tables')
json_for_create = UserMapping.representation_for(:create, user)
```

Some API's will give you the created resource back as JSON as well on a successful create. For that, you may do something like this:

```ruby
response = HTTPClient.post("http://something.com/api/users", body: json_for_create)
created_user = UserMapping.coerce_from(response.body, :read)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kartograph/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
