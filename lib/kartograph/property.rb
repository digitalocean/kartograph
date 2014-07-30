module Kartograph
  class Property
    attr_reader :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options
    end

    def value_for(object)
      object.send(name)
    end

    def scopes
      options[:scopes] || []
    end
  end
end