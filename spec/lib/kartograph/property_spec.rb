require 'spec_helper'

describe Kartograph::Property do
  describe '#initialize' do
    it 'initializes with an attribute name and options' do
      name = :hey
      options = { lol: 'whut' }

      property = Kartograph::Property.new(name, options)
      expect(property.name).to eq(name)
      expect(property.options).to eq(options)
      expect(property.key).to eq('hey')
    end

    context 'with a key' do
      it 'sets the key' do
        name = :hey
        options = { key: 'Hey' }
        property = Kartograph::Property.new(name, options)

        expect(property.key).to eq('Hey')
      end
    end

    context 'with a block' do
      it 'yields a map instance for the property' do
        expect {|b| Kartograph::Property.new(:hello, &b) }.to yield_with_args(Kartograph::Map.new)
      end
    end

    context 'with an include' do
      it 'sets the map to the included mapped class' do
        klass = Class.new do
          include Kartograph::DSL
          kartograph do
            property :lol, scopes: [:read]
          end
        end

        property = Kartograph::Property.new(:id, scopes: [:read], include: klass)
        expect(property.map).to eq(klass.kartograph)
      end
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

    it 'always casts to an array' do
      property = Kartograph::Property.new(:name, scopes: :read)
      expect(property.scopes).to eq [:read]
    end
  end

  describe '#plural?' do
    it 'returns true when set to plural' do
      property = Kartograph::Property.new(:name, scopes: [:read], plural: true)
      expect(property).to be_plural
    end

    it 'returns false when not set' do
      property = Kartograph::Property.new(:name, scopes: [:read])
      expect(property).to_not be_plural
    end
  end

  describe '#value_for' do
    it 'returns the value when passed an object' do
      property = Kartograph::Property.new(:sammy)
      object = double('object', sammy: 'cephalopod')

      expect(property.value_for(object)).to eq('cephalopod')
    end

    context 'for a nested property set' do
      it 'returns nested properties' do
        top_level = Kartograph::Property.new(:sammy) do
          property :cephalopod
        end

        child = double('child', cephalopod: 'I will ink you')
        root = double('root', sammy: child)

        expect(top_level.value_for(root)).to eq('cephalopod' => child.cephalopod)
      end

      context 'when it is plural' do
        it 'returns a pluralized representation' do
          top_level = Kartograph::Property.new(:sammy, plural: true) do
            property :cephalopod
          end

          child1 = double('child', cephalopod: 'I will ink you')
          child2 = double('child', cephalopod: 'I wont because im cool')

          root = double('root', sammy: [child1, child2])

          expect(top_level.value_for(root)).to eq([
            { 'cephalopod' => child1.cephalopod },
            { 'cephalopod' => child2.cephalopod }
          ])
        end
      end

      context 'when the value for the root object is nil' do
        it 'returns nil' do
          top_level = Kartograph::Property.new(:sammy) do
            property :cephalopod
          end

          root = double(sammy: nil)

          expect(top_level.value_for(root)).to be_nil
        end
      end
    end
  end

  describe '#value_from' do
    let(:hash) { { hello: 'world' } }

    it 'retrieves the value from a hash for the property' do
      property = Kartograph::Property.new(:hello)
      expect(property.value_from(hash)).to eq('world')
    end

    context 'for a nil object' do
      it 'bails and does not try to retrieve' do
        property = Kartograph::Property.new(:hello)
        value = property.value_from(nil)
        expect(value).to be_nil
      end
    end

    context 'string and symbol agnostic' do
      let(:hash) { { 'hello' => 'world' } }

      it 'retrieves the value from a hash for the property' do
        property = Kartograph::Property.new(:hello)
        expect(property.value_from(hash)).to eq('world')
      end
    end

    context 'for a nested property set' do
      it 'returns an object with the properties set on it' do
        dummy_class = Struct.new(:id, :name)

        nested_property = Kartograph::Property.new(:hello) do
          mapping dummy_class
          property :id
          property :name
        end

        hash = { hello: {
          'id' => 555,
          'name' => 'Buckstar'
        }}

        value = nested_property.value_from(hash)
        expect(value).to be_kind_of(dummy_class)
        expect(value.id).to eq(hash[:hello]['id'])
        expect(value.name).to eq(hash[:hello]['name'])
      end

      it 'returns a collection of objects when set to plural' do
        dummy_class = Struct.new(:id, :name)

        nested_property = Kartograph::Property.new(:hello, plural: true) do
          mapping dummy_class

          property :id
          property :name
        end

        hash = {
          hello: [{
            'id' => 555,
            'name' => 'Buckstar'
          }, {
            'id' => 556,
            'name' => 'Starbuck'
          }]
        }

        value = nested_property.value_from(hash)
        expect(value).to be_kind_of(Array)
        expect(value.size).to be(2)

        expect(value[0].id).to eq(hash[:hello][0]['id'])
        expect(value[0].name).to eq(hash[:hello][0]['name'])

        expect(value[1].id).to eq(hash[:hello][1]['id'])
        expect(value[1].name).to eq(hash[:hello][1]['name'])
      end

      context 'when set to plural but the key is nil' do
        it 'returns an empty array' do
          dummy_class = Struct.new(:id, :name)

          nested_property = Kartograph::Property.new(:hello, plural: true) do
            mapping dummy_class

            property :id
            property :name
          end

          hash = { hello: nil }
          value = nested_property.value_from(hash)

          expect(value).to eq([])
        end
      end
    end
  end

  describe '#dup' do
    it 'copies the name, options, and map into another property' do
      instance = Kartograph::Property.new(:id, scopes: [:read])
      duped = instance.dup

      expect(duped).to be_kind_of(Kartograph::Property)
      expect(duped.name).to eq(:id)
      expect(duped.options).to_not be(instance.options)
      expect(duped.options).to eq(instance.options)
    end

    context 'setting the map after duping' do
      it 'draws a value' do
        # NOTE: This test is a regression test introduced by caching of Artist instance.
        dummy_class = Struct.new(:id, :name)
        dummy = dummy_class.new
        dummy.id = 123

        instance = Kartograph::Property.new(:id, scopes: [:read])
        duped = instance.dup
        duped.map = Kartograph::Map.new
        val = duped.value_for(dummy)

        expect(val).to_not be_nil
      end
    end
  end
end
