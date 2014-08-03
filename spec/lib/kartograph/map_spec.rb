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

  describe '#dup' do
    it 'performs a safe duplication of the map' do
      mapped_class = Class.new

      prop1 = map.property :name, scopes: [:read, :write]
      prop2 = map.property :id, scopes: [:read]
      map.mapping mapped_class
      map.root_key singular: 'woot', plural: 'woots', scopes: [:read]

      new_map = map.dup

      expect(new_map.properties[0]).to_not be(prop1)
      expect(new_map.properties[1]).to_not be(prop2)

      expect(new_map.properties).to all(be_kind_of(Kartograph::Property))
      expect(new_map.properties[0].name).to eq(:name)
      expect(new_map.properties[1].name).to eq(:id)

      expect(new_map.mapping).to eq(mapped_class)
      expect(new_map.root_keys).to eq(map.root_keys)
    end
  end

  describe 'Equality' do
    specify 'duplicated maps are equal to eachother' do
      map1 = Kartograph::Map.new
      map1.property :something, scopes: [:read]

      map2 = map1.dup

      expect(map1).to eq(map2)
    end
  end
end