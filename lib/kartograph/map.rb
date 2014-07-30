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

    def root_keys(set = nil)
      @root_keys = set if set
      @root_keys
    end
  end
end