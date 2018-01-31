require 'spec_helper'

describe Kartograph::Artist do
  let(:map) { Kartograph::Map.new }
  let(:properties) { map.properties }

  describe '#initialize' do
    it 'initializes with an object and a map' do
      properties << Kartograph::Property.new(:name)

      artist = Kartograph::Artist.new(map)

      expect(artist.map).to be(map)
    end
  end

  describe '#draw' do
    it 'returns a hash of mapped properties' do
      object     = double('object', hello: 'world')
      properties << Kartograph::Property.new(:hello)

      artist = Kartograph::Artist.new(map)
      masterpiece = artist.draw(object)

      expect(masterpiece).to include('hello' => 'world')
    end

    it 'raises for a property that the object does not have' do
      class TestArtistNoMethod; end
      object = TestArtistNoMethod.new
      properties << Kartograph::Property.new(:bunk)
      artist = Kartograph::Artist.new(map)

      expect { artist.draw(object) }.to raise_error(ArgumentError).with_message("#{object} does not respond to bunk, so we can't map it")
    end

    context 'for a property with a key set on it' do
      it 'returns the hash with the key set correctly' do
        object     = double('object', hello: 'world')
        properties << Kartograph::Property.new(:hello, key: :hola)

        artist = Kartograph::Artist.new(map)
        masterpiece = artist.draw(object)

        expect(masterpiece).to include('hola' => 'world')
      end
    end

    context 'for filtered drawing' do
      it 'only returns the scoped properties' do
        object     = double('object', hello: 'world', foo: 'bar')
        properties << Kartograph::Property.new(:hello, scopes: [:create, :read])
        properties << Kartograph::Property.new(:foo, scopes: [:create])

        artist = Kartograph::Artist.new(map)
        masterpiece = artist.draw(object, :read)

        expect(masterpiece).to eq('hello' => 'world')
      end

      context 'on nested properties' do
        it 'only returns the nested properties within the same scope' do
          child = double('child', hello: 'world', foo: 'bunk')
          object = double('object', child: child)

          root_property = Kartograph::Property.new(:child, scopes: [:create, :read]) do
            property :hello, scopes: [:create]
            property :foo, scopes: [:read]
          end

          properties << root_property

          artist = Kartograph::Artist.new(map)
          masterpiece = artist.draw(object, :read)

          expect(masterpiece).to eq('child' => { 'foo' => child.foo })
        end
      end
    end

    context "with caching enabled" do
      let(:cacher) { double('cacher', fetch: { foo: 'cached-value' }) }
      let(:object) { double('object', foo: 'bar', cache_key: 'test-cache-key') }

      it "uses the cache fetch for values" do
        map.cache(cacher)
        map.cache_key { |obj, scope| obj.cache_key }
        map.property :foo

        artist = Kartograph::Artist.new(map)
        masterpiece = artist.draw(object)

        expect(masterpiece).to eq(cacher.fetch)

        expect(cacher).to have_received(:fetch).with('test-cache-key')
      end

      it "uses the cache key for the object and scope" do
        called = double(call: 'my-cache')

        map.cache(cacher)
        map.cache_key { |obj, scope| called.call(obj, scope) }

        map.property :foo, scopes: [:read]

        artist = Kartograph::Artist.new(map)
        masterpiece = artist.draw(object, :read)

        expect(called).to have_received(:call).with(object, :read)
      end
    end
  end
end
