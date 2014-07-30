module Kartograph
  class Artist
    attr_reader :object, :properties

    def initialize(object, properties)
      @object = object
      @properties = properties
    end

    def draw(scope = nil)
      scoped_properties = scope ? properties.filter_by_scope(scope) : properties
      scoped_properties.each_with_object({}) do |property, mapped|
        raise ArgumentError, "#{object} does not respond to #{property.name}, so we can't map it" unless object.respond_to?(property.name)
        mapped[property.name] = property.value_for(object)
      end
    end
  end
end