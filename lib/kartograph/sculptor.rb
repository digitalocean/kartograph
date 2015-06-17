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

    def sculpted_object
      # Fallback initialization of the object we're extracting into
      @sculpted_object ||= map.mapping.new
    end

    # Set this to pass in an object to extract into. Must
    # @param object must be of the same class as the map#mapping
    def sculpted_object=(object)
      raise ArgumentError unless object.is_a?(map.mapping)

      @sculpted_object = object
    end

    def sculpt(scope = nil)
      return nil if @object.nil?

      scoped_properties = scope ? properties.filter_by_scope(scope) : properties

      scoped_properties.each_with_object(sculpted_object) do |property, mutable|
        setter_method = "#{property.name}="
        value = property.value_from(object, scope)
        mutable.send(setter_method, value)
      end
    end
  end
end
