require 'kartograph'
require 'pp'

class User < Struct.new(:id, :name, :comments)
end

class Comment < Struct.new(:id, :text)
end

class UserMapping
  include Kartograph::DSL

  kartograph do
    mapping User

    property :id, scopes: [:read]
    property :name, scopes: [:read, :create]

    property :comments, plural: true, scopes: [:read] do
      mapping Comment

      property :id, scopes: [:read]
      property :text, scopes: [:read, :create]
    end
  end
end

user = User.new(1, 'he@he.com')
comment = Comment.new(12, 'aksjdfhasjkdfh')

user.comments = Array.new(3, comment)
users = Array.new(4, user)

json = UserMapping.represent_collection_for(:read, users)
puts "The JSON generated from that collection:"
puts json

users_again = UserMapping.extract_collection(json, :read)
puts "\n"
puts "And the JSON slurped back into an array:"
pp users_again