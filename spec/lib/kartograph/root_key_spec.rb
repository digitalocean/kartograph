require 'spec_helper'

describe Kartograph::RootKey do
  describe '#initialize' do
    it 'initializes with options' do
      options = { singular: 'hello', plural: 'hellos', scopes: [:read] }

      instance = Kartograph::RootKey.new(options)
      expect(instance.options).to eq(options)
    end
  end

  describe '#scopes' do
    it 'reads the scopes' do
      instance = Kartograph::RootKey.new(scopes: [:read])
      expect(instance.scopes).to eq([:read])
    end

    it 'reads the scopes as an array always' do
      instance = Kartograph::RootKey.new(scopes: :read)
      expect(instance.scopes).to eq([:read])
    end
  end

  describe '#singular' do
    it 'reads the singular key' do
      instance = Kartograph::RootKey.new(singular: 'user')
      expect(instance.singular).to eq('user')
    end
  end

  describe '#plural' do
    it 'reads the plural key' do
      instance = Kartograph::RootKey.new(plural: 'user')
      expect(instance.plural).to eq('user')
    end
  end
end