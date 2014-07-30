require 'spec_helper'

describe Kartograph::Map do
  subject(:map) { Kartograph::Map.new }

  describe '#property' do
    it 'adds a property to the map' do
      map.property :attribute_name, scopes: [:read]
      expect(map.properties.size).to be(1)
      expect(map.properties.first).to be_kind_of(Kartograph::Property)
    end
  end

  describe '#properties' do
    it 'returns a PropertyCollection object' do
      properties = map.properties
      expect(properties).to be_kind_of(Kartograph::PropertyCollection)
    end
  end

  describe '#mapping' do
    it 'sets the class we\'re mapping' do
      map.mapping Class
      expect(map.mapping).to be(Class)
    end
  end

  describe '#root_key' do
    it 'sets the root keys' do
      map.root_key singlular: 'test', scopes: [:read]
      map.root_key singlular: 'test', scopes: [:create]

      expect(map.root_keys.size).to be(2)
      expect(map.root_keys).to all(be_kind_of(Kartograph::RootKey))
    end
  end

  describe '#root_key_for' do
    it 'returns the first root key for the scope and type' do
      map.root_key singular: 'test', scopes: [:read]
      key = map.root_key_for(:read, :singular)

      expect(key).to eq('test')
    end
  end
end