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

    def value_for(object)
      value = object.send(name)
      map ? artist_value(value) : value
    end

    def value_from(object)
      value = object.has_key?(name) ? object[name] : object[name.to_s]
      map ? sculpt_value(value) : value
    end

    def scopes
      options[:scopes] || []
    end

    def plural?
      !!options[:plural]
    end

    private

    def sculpt_value(value)
      if plural?
        value.map {|v| Sculptor.new(v, map).sculpt }
      else
        Sculptor.new(value, map).sculpt
      end
    end

    def artist_value(value)
      if plural?
        value.map {|v| Artist.new(v, map).draw }
      else
        Artist.new(value, map).draw
      end
    end
  end
end