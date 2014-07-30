shared_context "DSL Objects" do
  let(:object) { double('object', id: 1066, name: 'Bruce (the dude from Finding Nemo)') }
  let(:mapped) do
    Class.new do
      include Kartograph::DSL

      kartograph do
        mapping DummyUser

        property :id, scopes: [:read]
        property :name, scopes: [:read, :create]

        property :comments, plural: true do
          mapping DummyComment

          property :id, scopes: [:read]
          property :text, scopes: [:read, :create]
        end
      end
    end
  end
end