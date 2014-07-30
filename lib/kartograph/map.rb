module Kartograph
  class Map
    def property(*args, &block)
      properties << Property.new(*args, &block)
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
  end
end