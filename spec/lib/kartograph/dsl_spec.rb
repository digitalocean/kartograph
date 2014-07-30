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
    include_context 'DSL Objects'

    it 'returns the JSON representation for an object' do
      json = mapped.representation_for(:create, object)
      expect(json).to eq(
        { name: object.name }.to_json
      )
    end
  end

  describe '.extract_single' do
    include_context 'DSL Objects'
    let(:json) do
      { id: 1337, name: 'Paul the octopus' }.to_json
    end

    it 'returns a populated object from a JSON representation' do
      extracted = mapped.extract_single(json, :read)

      expect(extracted.id).to eq(1337)
      expect(extracted.name).to eq('Paul the octopus')
    end
  end
end