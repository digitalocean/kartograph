module Kartograph
  class Property
    attr_reader :name, :options
    attr_accessor :map

    def initialize(name, options = {}, &block)
      @name = name
      @options = options

      if mapped_class = options[:include]
        # Perform a safe duplication into our properties map
        # This allows the user to define more attributes on the map should they need to
        @map = mapped_class.kartograph.dup
      end

      if block_given?
        @map ||= Map.new
        block.arity > 0 ? block.call(map) : map.instance_eval(&block)
      end
    end

    def value_for(object, scope = nil)
      value = object.send(name)
      map ? artist_value(value, scope) : value
    end

    def value_from(object, scope = nil)
      return if object.nil?
      value = object.has_key?(name) ? object[name] : object[name.to_s]
      return if value.nil?
      map ? sculpt_value(value, scope) : value
    end

    def scopes
      Array(options[:scopes] || [])
    end

    def plural?
      !!options[:plural]
    end

    def dup
      Property.new(name, options.dup).tap do |property|
        property.map = map.dup if self.map
      end
    end

    def ==(other)
      %i(name options map).inject(true) do |equals, method|
        break unless equals
        send(method) == other.send(method)
      end
    end

    private

    def sculpt_value(value, scope)
      plural? ? value.map {|v| Sculptor.new(v, map).sculpt(scope) } : Sculptor.new(value, map).sculpt(scope)
    end

    def artist_value(value, scope)
      plural? ? value.map {|v| Artist.new(v, map).draw(scope) } : Artist.new(value, map).draw(scope)
    end
  end
end