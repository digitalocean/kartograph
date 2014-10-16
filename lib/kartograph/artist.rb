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
      scoped_properties = scope ? properties.filter_by_scope(scope) : properties
      scoped_properties.each_with_object({}) do |property, mapped|
        raise ArgumentError, "#{object} does not respond to #{property.name}, so we can't map it" unless object.respond_to?(property.name)

        mapped[property.key] = if map.cache
          extract_from_cache(property, scope)
        else
          extract_from_object(property, scope)
        end
      end
    end

    private

    def extract_from_object(property, scope)
      property.value_for(object, scope)
    end

    def extract_from_cache(property, scope)
      key = map.cache_key.call(object, scope)

      map.cache.fetch(key) do
        extract_from_object(property, scope)
      end
    end
  end
end