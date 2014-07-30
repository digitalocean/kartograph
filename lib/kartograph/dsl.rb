module Kartograph
  module DSL
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def kartograph(&block)
        @kartograph_map ||= Map.new

        block.arity > 0 ? block.call(@kartograph_map) : @kartograph_map.instance_eval(&block)
      end

      def representation_for(scope, object, dumper = JSON)
        drawed = Artist.new(object, @kartograph_map).draw(scope)

        if root_key = @kartograph_map.root_key_for(scope, :singular)
          drawed = { root_key => drawed }
        end

        dumper.dump(drawed)
      end

      def extract_single(content, scope, loader = JSON)
        loaded = loader.load(content)

        if root_key = @kartograph_map.root_key_for(scope, :singular)
          loaded = loaded[root_key]
        end

        Sculptor.new(loaded, @kartograph_map).sculpt(scope)
      end
    end
  end
end