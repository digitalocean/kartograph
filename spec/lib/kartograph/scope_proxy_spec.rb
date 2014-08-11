require 'spec_helper'

RSpec.describe Kartograph::ScopeProxy do
  describe '#initialize' do
    it 'initializes with a map, scopes, and a block' do
      map, scopes = double, [:read, :write]

      instance = Kartograph::ScopeProxy.new(map, scopes)

      expect(instance.map).to be(map)
      expect(instance.scopes).to be(scopes)
    end
  end

  describe '#property' do
    let(:map) { Kartograph::Map.new }
    subject(:proxy) { Kartograph::ScopeProxy.new(map, [:read, :write]) }

    it 'adds a property to the properties with the correct scope' do
      proxy.property :hello
      proxy.property :world

      read_properties = map.properties.filter_by_scope(:read)
      expect(read_properties.map(&:name)).to eq([:hello, :world])

      write_properties = map.properties.filter_by_scope(:write)
      expect(write_properties.map(&:name)).to eq([:hello, :world])
    end
  end
end