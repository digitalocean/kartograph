module Kartograph
  class Map
    def property(*args)
      properties << Property.new(*args)
    end

    def properties
      @properties ||= []
    end
  end
end