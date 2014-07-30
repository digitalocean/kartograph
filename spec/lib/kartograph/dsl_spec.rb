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
end