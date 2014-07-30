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

        retrieve_root_key(scope, :singular) do |root_key|
          # Reassign drawed if a root key exists
          drawed = { root_key => drawed }
        end

        dumper.dump(drawed)
      end

      def extract_single(content, scope, loader = JSON)
        loaded = loader.load(content)

        retrieve_root_key(scope, :singular) do |root_key|
          # Reassign loaded if a root key exists
          loaded = loaded[root_key]
        end

        Sculptor.new(loaded, @kartograph_map).sculpt(scope)
      end

      def extract_collection(content, scope, loader = JSON)
        loaded = loader.load(content)

        retrieve_root_key(scope, :plural) do |root_key|
          # Reassign loaded if a root key exists
          loaded = loaded[root_key]
        end

        loaded.map do |object|
          Sculptor.new(object, @kartograph_map).sculpt(scope)
        end
      end

      private

      def retrieve_root_key(scope, type, &block)
        if root_key = @kartograph_map.root_key_for(scope, type)
          yield root_key
        end
      end
    end
  end
end