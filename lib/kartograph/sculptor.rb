module Kartograph
  class Sculptor
    attr_reader :object, :map

    def initialize(object, map)
      @object = object
      @map = map
    end

    def properties
      map.properties
    end

    def sculpt(scope = nil)
      return nil if @object.nil?

      # Initializing the object we're coercing so we can set attributes on it
      coerced = map.mapping.new
      scoped_properties = scope ? properties.filter_by_scope(scope) : properties

      scoped_properties.each_with_object(coerced) do |property, mutable|
        setter_method = "#{property.name}="
        value = property.value_from(object, scope)
        mutable.send(setter_method, value)
      end
    end
  end
end
