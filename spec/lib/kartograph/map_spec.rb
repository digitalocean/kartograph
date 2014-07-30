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
end