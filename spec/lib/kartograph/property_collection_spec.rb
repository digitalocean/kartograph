require 'spec_helper'

describe Kartograph::PropertyCollection do
  describe '#filter_by_scope' do
    it 'only returns properties with a certain scope attached' do
      collection = Kartograph::PropertyCollection.new
      collection << Kartograph::Property.new(:hello, scopes: [:read, :create])
      collection << Kartograph::Property.new(:id, scopes: [:read])

      filtered = collection.filter_by_scope(:create)
      expect(filtered.size).to be(1)
      expect(filtered.first.name).to eq(:hello)
    end
  end
end