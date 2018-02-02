module Kartograph
  class Property
    attr_reader :name, :options, :map

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

      @artist = Artist.new(@map)
    end

    def key
      @key ||= (options[:key] || name).to_s.freeze
      @key
    end

    def map=(map)
      @map = map
      @artist = Artist.new(@map)
    end

    def value_for(object, scope = nil)
      value = object.send(name)
      return if value.nil?
      map ? artist_value(value, scope) : value
    end

    def value_from(object, scope = nil)
      return if object.nil?
      value = object.has_key?(key) ? object[key] : object[key.to_sym]
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
      plural? ? Array(value).map {|v| Sculptor.new(v, map).sculpt(scope) } : Sculptor.new(value, map).sculpt(scope)
    end

    def artist_value(value, scope)
      plural? ? Array(value).map {|v| @artist.draw(v, scope) } : @artist.draw(value, scope)
    end
  end
end
