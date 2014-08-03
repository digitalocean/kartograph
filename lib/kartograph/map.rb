module Kartograph
  class Map
    def property(*args, &block)
      Property.new(*args, &block).tap {|p| properties << p }
    end

    def properties
      @properties ||= PropertyCollection.new
    end

    def root_keys
      @root_keys ||= []
    end

    def mapping(klass = nil)
      @mapping = klass if klass
      @mapping
    end

    def root_key(options)
      root_keys << RootKey.new(options)
    end

    def root_key_for(scope, type)
      return unless %i(singular plural).include?(type)

      if (root_key = root_keys.select {|rk| rk.scopes.include?(scope) }[0])
        root_key.send(type)
      end
    end

    def dup
      Kartograph::Map.new.tap do |map|
        self.properties.each do |property|
          map.properties << property.dup
        end
      end
    end

    def ==(other)
      methods = %i(properties root_keys mapping)
      methods.inject(true) do |current_value, method|
        break unless current_value
        send(method) == other.send(method)
      end
    end
  end
end