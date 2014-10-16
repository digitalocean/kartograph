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

  class << self
    attr_accessor :default_dumper
    attr_accessor :default_loader
    attr_accessor :default_cache
    attr_accessor :default_cache_key
  end

  self.default_dumper = JSON
  self.default_loader = JSON
end
