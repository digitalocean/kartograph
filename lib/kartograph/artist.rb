module Kartograph
  class Artist
    attr_reader :object, :map

    def initialize(object, map)
      @object = object
      @map = map
    end

    def properties
      map.properties
    end

    def draw(scope = nil)
      if map.cache
        cache_key = map.cache_key.call(object, scope)
        map.cache.fetch(cache_key) { build_properties(scope) }
      else
        build_properties(scope)
      end
    end

    def build_properties(scope)
      scoped_properties = scope ? properties.filter_by_scope(scope) : properties
      scoped_properties.each_with_object({}) do |property, mapped|
        raise ArgumentError, "#{object} does not respond to #{property.name}, so we can't map it" unless object.respond_to?(property.name)

        mapped[property.key] = property.value_for(object, scope) unless property.value_for(object, scope).nil? && property.optional?
      end
    end
  end
end