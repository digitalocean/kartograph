module Kartograph
  class Artist
    attr_reader :map

    def initialize(map)
      @map = map
    end

    def properties
      map.properties
    end

    def draw(object, scope = nil)
      if map.cache
        cache_key = map.cache_key.call(object, scope)
        map.cache.fetch(cache_key) { build_properties(object, scope) }
      else
        build_properties(object, scope)
      end
    end

    def build_properties(object, scope)
      scoped_properties = scope ? properties.filter_by_scope(scope) : properties
      scoped_properties.each_with_object({}) do |property, mapped|
        begin
          mapped[property.key] = property.value_for(object, scope)
        rescue NoMethodError => e
          raise ArgumentError, "#{object} does not respond to #{property.name}, so we can't map it"
        end
      end
    end
  end
end
