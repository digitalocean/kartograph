require 'spec_helper'

describe Kartograph::Artist do
  describe '#initialize' do
    it 'initializes with an object and list of properties' do
      object     = double('object', name: 'hello')
      collection = Kartograph::PropertyCollection.new
      collection << Kartograph::Property.new(:name)

      artist = Kartograph::Artist.new(object, collection)

      expect(artist.object).to be(object)
      expect(artist.properties).to be(collection)
    end
  end

  describe '#draw' do
    let(:collection) { Kartograph::PropertyCollection.new }

    it 'returns a hash of mapped properties' do
      object     = double('object', hello: 'world')
      collection << Kartograph::Property.new(:hello)

      artist = Kartograph::Artist.new(object, collection)
      masterpiece = artist.draw

      expect(masterpiece).to include(hello: 'world')
    end

    it 'raises for a property that the object does not have' do
      object = double('object')
      collection << Kartograph::Property.new(:bunk)
      artist = Kartograph::Artist.new(object, collection)

      expect { artist.draw }.to raise_error(ArgumentError).with_message("#{object} does not respond to bunk, so we can't map it")
    end

    context 'for filtered drawing' do
      it 'only returns the scoped properties' do
        object     = double('object', hello: 'world', foo: 'bar')
        collection << Kartograph::Property.new(:hello, scopes: [:create, :read])
        collection << Kartograph::Property.new(:foo, scopes: [:create])

        artist = Kartograph::Artist.new(object, collection)
        masterpiece = artist.draw(:read)

        expect(masterpiece).to eq(hello: 'world')
      end
    end
  end
end