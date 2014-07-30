module Kartograph
  class Property
    attr_reader :name, :options, :map

    def initialize(name, options = {}, &block)
      @name = name
      @options = options

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
      value = object.has_key?(name) ? object[name] : object[name.to_s]
      map ? sculpt_value(value, scope) : value
    end

    def scopes
      options[:scopes] || []
    end

    def plural?
      !!options[:plural]
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