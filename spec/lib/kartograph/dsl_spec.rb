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
      expect {|b| mapping.kartograph(&b) }.to yield_with_args(Kartograph::Map.new)
    end

    it 'returns the map instance' do
      expect(mapping.kartograph).to be_kind_of(Kartograph::Map)
    end
  end

  describe '.hash_for' do
    include_context 'DSL Objects'

    it 'returns the hash representation for an object' do
      hash = mapped.hash_for(:create, object)
      expect(hash).to eq({ 'name' => object.name })
    end

    context 'with a root key for the scope' do
      it 'returns the hash with the root key' do
        mapped.kartograph do
          root_key singular: 'user', scopes: [:create]
        end
        hash = mapped.hash_for(:create, object)

        expect(hash).to eq(
          {
            'user' => {
              'name' => object.name
            }
          }
        )
      end
    end
  end

  describe '.hash_collection_for' do
    include_context 'DSL Objects'

    let(:users) { Array.new(3, object) }

    subject(:parsed) do
      json = mapped.represent_collection_for(:read, users)
      JSON.parse(json)
    end

    it 'returns the objects as a collection of hashes' do
      collection = mapped.hash_collection_for(:read, users)

      expect(collection).to be_an(Array)
      expect(collection.size).to be(3)

      expect(collection[0]['id']).to   eq(users[0].id)
      expect(collection[0]['name']).to eq(users[0].name)
      expect(collection[1]['id']).to   eq(users[1].id)
      expect(collection[1]['name']).to eq(users[1].name)
    end

    context 'with a root key' do
      it "includes the root key" do
        root_key_name = "the_root_key"

        mapped.kartograph do
          root_key plural: root_key_name, scopes: [:read]
        end

        collection = mapped.hash_collection_for(:read, users)

        expect(collection).to be_an(Hash)
        expect(collection.keys.first).to eq(root_key_name)

        collection_array = collection[root_key_name]
        expect(collection_array[0]['id']).to   eq(users[0].id)
        expect(collection_array[0]['name']).to eq(users[0].name)
        expect(collection_array[1]['id']).to   eq(users[1].id)
        expect(collection_array[1]['name']).to eq(users[1].name)
      end
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

    context 'with a root key for the scope' do
      it 'returns the json with the root key' do
        mapped.kartograph do
          root_key singular: 'user', scopes: [:create]
        end
        json = mapped.representation_for(:create, object)

        expect(json).to eq(
          {
            user: {
              name: object.name
            }
          }.to_json
        )
      end
    end
  end

  describe '.represent_collection_for' do
    include_context 'DSL Objects'

    let(:users) { Array.new(3, object) }

    subject(:parsed) do
      json = mapped.represent_collection_for(:read, users)
      JSON.parse(json)
    end

    it 'returns the objects as a collection' do
      json = mapped.represent_collection_for(:read, users)
      parsed = JSON.parse(json)

      expect(parsed).to be_an(Array)
      expect(parsed.size).to be(3)

      expect(parsed[0]['id']).to   eq(users[0].id)
      expect(parsed[0]['name']).to eq(users[0].name)
      expect(parsed[1]['id']).to   eq(users[1].id)
      expect(parsed[1]['name']).to eq(users[1].name)
    end

    context 'with a root key' do
      it "includes the root key" do
        root_key_name = "the_root_key"

        mapped.kartograph do
          root_key plural: root_key_name, scopes: [:read]
        end

        expect(parsed).to be_an(Hash)
        expect(parsed.keys.first).to eq(root_key_name)

        parsed_array = parsed[root_key_name]
        expect(parsed_array[0]['id']).to   eq(users[0].id)
        expect(parsed_array[0]['name']).to eq(users[0].name)
        expect(parsed_array[1]['id']).to   eq(users[1].id)
        expect(parsed_array[1]['name']).to eq(users[1].name)
      end
    end
  end

  describe '.extract_single' do
    include_context 'DSL Objects'
    let(:json) do
      { id: 1337, name: 'Paul the octopus' }
    end

    it 'returns a populated object from a JSON representation' do
      extracted = mapped.extract_single(json.to_json, :read)

      expect(extracted.id).to eq(1337)
      expect(extracted.name).to eq('Paul the octopus')
    end

    context 'with a root key in the JSON' do
      let(:json) { { test: super() } }

      before do
        mapped.kartograph do
          root_key singular: 'test', scopes: [:read]
        end
      end

      it 'traverses into the key and pulls the object from there' do
        extracted = mapped.extract_single(json.to_json, :read)

        expect(extracted.id).to eq(1337)
        expect(extracted.name).to eq('Paul the octopus')
      end
    end
  end

  describe '.extract_into_object' do
    include_context 'DSL Objects'
    let(:json) do
      { id: 1337, name: 'Paul the octopus' }
    end

    it 'returns a populated object from a JSON representation' do
      object = DummyUser.new
      mapped.extract_into_object(object, json.to_json, :read)

      expect(object.id).to eq(1337)
      expect(object.name).to eq('Paul the octopus')
    end
  end

  describe '.extract_collection' do
    include_context 'DSL Objects'
    let(:json) do
      [
        { id: 1337, name: 'Paul the octopus' },
        { id: 1338, name: 'Hank the octopus' }
      ]
    end

    it 'returns a collection of objects from the json' do
      extracted = mapped.extract_collection(json.to_json, :read)

      expect(extracted.size).to be(2)
      expect(extracted).to all(be_kind_of(DummyUser))

      expect(extracted[0].id).to eq(json[0][:id])
      expect(extracted[0].name).to eq(json[0][:name])

      expect(extracted[1].id).to eq(json[1][:id])
      expect(extracted[1].name).to eq(json[1][:name])
    end

    context 'for a nested key' do
      let(:json) { { users: super() } }

      before do
        mapped.kartograph do
          root_key plural: 'users', scopes: [:read]
        end
      end

      it 'returns a collection of objects from the json' do
        extracted = mapped.extract_collection(json.to_json, :read)

        expect(extracted.size).to be(2)
        expect(extracted).to all(be_kind_of(DummyUser))

        scoped = json[:users]

        expect(extracted[0].id).to eq(scoped[0][:id])
        expect(extracted[0].name).to eq(scoped[0][:name])

        expect(extracted[1].id).to eq(scoped[1][:id])
        expect(extracted[1].name).to eq(scoped[1][:name])
      end
    end
  end
end
