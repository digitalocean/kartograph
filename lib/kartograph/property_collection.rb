require 'forwardable'

module Kartograph
  class PropertyCollection
    # Make this collection quack like an array
    # http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
    extend Forwardable
    def_delegators :@collection, *(Array.instance_methods - Object.instance_methods)

    def initialize(*)
      @collection = []
    end

    def filter_by_scope(scope)
      select do |property|
        property.scopes.include?(scope)
      end
    end

    def ==(other)
      each_with_index.inject(true) do |current_value, (property, index)|
        break unless current_value
        property == other[index]
      end
    end
  end
end