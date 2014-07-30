require 'spec_helper'

describe Kartograph::Sculptor do
  describe '#initialize' do
    it 'initializes with a hash and map' do
      hash = {}
      map = double('im a map')

      sculptor = Kartograph::Sculptor.new(hash, map)

      expect(sculptor.object).to be(hash)
      expect(sculptor.map).to be(map)
    end
  end

  describe '#sculpt' do
    let(:map) { Kartograph::Map.new }
    let(:object) { { 'id' => 343, 'name' => 'Guilty Spark' } }

    context 'without a scope' do
      before do
        map.mapping DummyUser
        map.property :id, scopes: [:read]
        map.property :name, scopes: [:read, :create]
      end

      it 'returns a coerced user' do
        sculptor = Kartograph::Sculptor.new(object, map)
        sculpted = sculptor.sculpt

        expect(sculpted).to be_kind_of(DummyUser)
        expect(sculpted.id).to eq(object['id'])
        expect(sculpted.name).to eq(object['name'])
      end
    end

    context 'with a scope' do
      before do
        map.mapping DummyUser
        map.property :id, scopes: [:read]
        map.property :name, scopes: [:create]
      end

      it 'returns a coerced user' do
        sculptor = Kartograph::Sculptor.new(object, map)
        sculpted = sculptor.sculpt(:read)

        expect(sculpted).to be_kind_of(DummyUser)
        expect(sculpted.id).to eq(object['id'])
        expect(sculpted.name).to be_nil
      end

      context 'for nested properties' do
        let(:object) { super().merge('comment' => { 'id' => 123, 'text' => 'hello' }) }

        before do
          map.property :comment, scopes: [:read] do
            mapping DummyComment

            property :id, scopes: [:read]
            property :text, scopes: [:create]
          end
        end

        it 'returns the nested objects with scoped properties set' do
          sculptor = Kartograph::Sculptor.new(object, map)
          sculpted = sculptor.sculpt(:read)

          expect(sculpted.comment).to be_kind_of(DummyComment)
          expect(sculpted.comment.id).to eq(123)
          expect(sculpted.comment.text).to be_nil
        end
      end
    end
  end
end