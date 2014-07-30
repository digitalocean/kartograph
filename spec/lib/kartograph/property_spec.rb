require 'spec_helper'

describe Kartograph::Property do
  describe '#initialize' do
    it 'initializes with an attribute name and options' do
      name = :hey
      options = { lol: 'whut' }

      property = Kartograph::Property.new(name, options)
      expect(property.name).to eq(name)
      expect(property.options).to eq(options)
    end
  end

  describe '#scopes' do
    it 'returns the scopes that the property is for' do
      property = Kartograph::Property.new(:name, scopes: [:read, :create])
      expect(property.scopes).to include(:read, :create)
    end

    it 'returns an empty array when no scopes are provided' do
      property = Kartograph::Property.new(:name)
      expect(property.scopes).to eq( [] )
    end
  end

  describe '#value_for' do
    it 'returns the value when passed an object' do
      property = Kartograph::Property.new(:sammy)
      object = double('object', sammy: 'cephalopod')

      expect(property.value_for(object)).to eq('cephalopod')
    end
  end
end