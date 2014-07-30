module Kartograph
  module DSL
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def kartograph(&block)
        @map ||= Map.new
        yield @map
      end
    end
  end
end