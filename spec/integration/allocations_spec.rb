require 'spec_helper'

stack_prof_mode = false
begin
  # Add stackprof to the gemfile to test it
  require 'stackprof'
  stack_prof_mode = true
rescue LoadError
end

class Node
  attr_accessor :props

  def initialize
    @props = {}
  end

  def method_missing(m, *args, &block)
    name = m.to_s.chomp('=')

    if m.to_s.include?'='
      @props[name] = args[0]
      define_singleton_method(name) do
        args[0]
      end
    else
      super
    end
  end
end

def generate_mapping(root_node)
  klass = Class.new { include Kartograph::DSL }

  klass.kartograph do |map|
    root_node.props.each do |k, v|
      case v
      when Node
        map.property k.to_sym, include: generate_mapping(v), scopes: [:read]
      when Array
        if v.size == 0 || v[0].class != Node
          map.property k.to_sym, scopes: [:read]
        else
          map.property k.to_sym, include: generate_mapping(v[0]), plural: true, scopes: [:read]
        end
      else
        map.property k.to_sym, scopes: [:read]
      end
    end
  end

  klass
end

def generate_nodes(json_data)
  case json_data
  when Hash
    root = Node.new
    json_data.each do |k, v|
      root.send(k + '=', generate_nodes(v))
    end

    root
  when Array
    json_data.map {|v| generate_nodes(v) }
  else
    json_data
  end
end

def load_data(file)
  JSON.parse(File.read(file))
end

describe 'rendering a complex model' do
  it 'generates a matchin JSON output' do
    testfiles = Dir[File.join(File.dirname(__FILE__), 'testdata', '*.json')]
    testfiles.each do |file|
      filename = File.basename(file)
      data = load_data(file)
      nodes = generate_nodes(data)

      mapping = generate_mapping(nodes)

      resulting_json = nil
      generate_json = lambda do
        resulting_json = mapping.representation_for(:read, nodes)
      end

      if stack_prof_mode
        StackProf.run(mode: :object, raw: true, out: "stackprof-#{filename}.dump", &generate_json)
      else
        generate_json.call
      end

      expect(resulting_json).to eq(data.to_json)
    end
  end
end

