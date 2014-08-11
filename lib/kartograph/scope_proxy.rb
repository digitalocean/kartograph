module Kartograph
  class ScopeProxy
    attr_reader :map, :scopes

    def initialize(map, scopes)
      @map, @scopes = map, scopes
    end

    def property(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:scopes] = scopes
      args << options

      map.property(*args, &block)
    end
  end
end