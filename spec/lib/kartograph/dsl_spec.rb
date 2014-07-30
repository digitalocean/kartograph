require 'spec_helper'

describe Kartograph::DSL do
  describe 'Inclusion' do
    it 'gives you a class method for .kartograph' do
      klass = Class.new
      expect { klass.send(:include, described_class) }.to change { klass.respond_to?(:kartograph) }.to(true)
    end
  end

  describe '.kartograph' do
    subject(:mapping) { Class.new { include Kartograph::DSL } }

    it 'yields a Kartograph::Map instance' do
      expect {|b| mapping.kartograph(&b) }.to yield_with_args(instance_of(Kartograph::Map))
    end
  end

  describe '.representation_for' do
    let(:object) { double('object', id: 1066, name: 'Bruce (the dude from Finding Nemo)') }
    let(:mapped) do
      Class.new do
        include Kartograph::DSL

        kartograph do
          property :id, scopes: [:read]
          property :name, scopes: [:read, :create]
        end
      end
    end

    it 'returns the JSON representation for an object' do
      json = mapped.representation_for(:create, object)
      expect(json).to eq(
        { name: object.name }.to_json
      )
    end
  end
end