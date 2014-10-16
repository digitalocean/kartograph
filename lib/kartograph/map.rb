module Kartograph
  class Map
    def property(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |prop|
        properties << Property.new(prop, options, &block)
      end
    end

    def properties
      @properties ||= PropertyCollection.new
    end

    def scoped(*scopes, &block)
      proxy = ScopeProxy.new(self, scopes)
      proxy.instance_eval(&block)
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

    def cache(object = nil)
      @cache = object unless object.nil?
      @cache.nil? ? Kartograph.default_cache : @cache
    end

    def cache_key(&calculator)
      @cache_calculator = calculator if block_given?
      @cache_calculator.nil? ? Kartograph.default_cache_key : @cache_calculator
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

        map.mapping self.mapping

        self.root_keys.each do |rk|
          map.root_keys << rk
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