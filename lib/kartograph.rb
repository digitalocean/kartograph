require "kartograph/version"
require 'json'

module Kartograph
  autoload :DSL, 'kartograph/dsl'
  autoload :Map, 'kartograph/map'
  autoload :Property, 'kartograph/property'
  autoload :PropertyCollection, 'kartograph/property_collection'

  autoload :Artist, 'kartograph/artist'
  autoload :Sculptor, 'kartograph/sculptor'
end
