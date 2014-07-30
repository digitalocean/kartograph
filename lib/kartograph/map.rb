module Kartograph
  class Map
    def property(*args)
      properties << Property.new(*args)
    end

    def properties
      @properties ||= PropertyCollection.new
    end

    def mapping(klass = nil)
      @mapping = klass if klass
      @mapping
    end
  end
end