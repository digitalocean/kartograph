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
    it 'returns a hash of mapped properties' do
      object     = double('object', hello: 'world')
      collection = Kartograph::PropertyCollection.new
      collection << Kartograph::Property.new(:hello)

      artist = Kartograph::Artist.new(object, collection)
      masterpiece = artist.draw

      expect(masterpiece).to include(hello: 'world')
    end

    context 'for filtered drawing' do
      it 'only returns the scoped properties' do
        object     = double('object', hello: 'world', foo: 'bar')
        collection = Kartograph::PropertyCollection.new
        collection << Kartograph::Property.new(:hello, scopes: [:create, :read])
        collection << Kartograph::Property.new(:foo, scopes: [:create])

        artist = Kartograph::Artist.new(object, collection)
        masterpiece = artist.draw(:read)

        expect(masterpiece).to eq(hello: 'world')
      end
    end
  end
end