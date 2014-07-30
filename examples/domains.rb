require 'kartograph'

json = '{
  "domains": [
    {
      "name": "example.com",
      "ttl": 1800,
      "zone_file": "Example zone file text..."
    }
  ],
  "meta": {
    "total": 1
  }
}'

class Domain
  attr_accessor :name, :ttl, :zone_file
end

class MetaInformation
  attr_accessor :total
end

class DomainMapper
  include Kartograph::DSL

  kartograph do
    mapping Domain
    root_key singular: 'domain', plural: 'domains', scopes: [:read]

    property :name, scopes: [:read]
    property :ttl, scopes: [:read]
    property :zone_file, scopes: [:read]
  end
end

class MetaInformationMapper
  include Kartograph::DSL

  kartograph do
    mapping MetaInformation

    root_key singular: 'meta', scopes: [:read]
    property :total, scopes: [:read]
  end
end

domains = DomainMapper.extract_collection(json, :read)
meta = MetaInformationMapper.extract_single(json, :read)

puts "Total Domains: #{domains.size}"
puts domains.map(&:name)
puts
puts "Total pages: #{meta.total}"