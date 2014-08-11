require "kartograph/version"
require 'json'

module Kartograph
  autoload :DSL, 'kartograph/dsl'
  autoload :Map, 'kartograph/map'
  autoload :Property, 'kartograph/property'
  autoload :PropertyCollection, 'kartograph/property_collection'
  autoload :RootKey, 'kartograph/root_key'
  autoload :ScopeProxy, 'kartograph/scope_proxy'

  autoload :Artist, 'kartograph/artist'
  autoload :Sculptor, 'kartograph/sculptor'
end
