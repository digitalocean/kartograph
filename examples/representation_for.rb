class Domain
  attr_accessor :name, :ttl, :zone_file
end

class DomainMapper
  include Kartograph::DSL

  kartograph do
    mapping Domain
    root_key singular: 'domain', plural: 'domains', scopes: [:read]

    property :name, scopes: [:read, :create]
    property :ttl, scopes: [:read, :create]
    property :zone_file, scopes: [:read]
  end
end

domain = Domain.new
domain.name = 'example.com'
domain.ttl = 3600
domain.zone_file = "this wont be represented for create"

puts DomainMapper.representation_for(:create, domain)
#=> {"name":"example.com","ttl":3600}