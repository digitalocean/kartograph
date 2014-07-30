require 'spec_helper'

describe Kartograph::Artist do
  let(:map) { Kartograph::Map.new }
  let(:properties) { map.properties }

  describe '#initialize' do
    it 'initializes with an object and a map' do
      object     = double('object', name: 'hello')
      properties << Kartograph::Property.new(:name)

      artist = Kartograph::Artist.new(object, map)

      expect(artist.object).to be(object)
      expect(artist.map).to be(map)
    end
  end

  describe '#draw' do
    it 'returns a hash of mapped properties' do
      object     = double('object', hello: 'world')
      properties << Kartograph::Property.new(:hello)

      artist = Kartograph::Artist.new(object, map)
      masterpiece = artist.draw

      expect(masterpiece).to include(hello: 'world')
    end

    it 'raises for a property that the object does not have' do
      object = double('object')
      properties << Kartograph::Property.new(:bunk)
      artist = Kartograph::Artist.new(object, map)

      expect { artist.draw }.to raise_error(ArgumentError).with_message("#{object} does not respond to bunk, so we can't map it")
    end

    context 'for filtered drawing' do
      it 'only returns the scoped properties' do
        object     = double('object', hello: 'world', foo: 'bar')
        properties << Kartograph::Property.new(:hello, scopes: [:create, :read])
        properties << Kartograph::Property.new(:foo, scopes: [:create])

        artist = Kartograph::Artist.new(object, map)
        masterpiece = artist.draw(:read)

        expect(masterpiece).to eq(hello: 'world')
      end
    end
  end
end