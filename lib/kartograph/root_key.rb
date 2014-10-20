module Kartograph
  class RootKey
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def scopes
      Array(options[:scopes]) || []
    end

    %i(singular plural).each do |method|
      define_method(method) do
        options[method]
      end
    end
  end
end