# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kartograph/version'

Gem::Specification.new do |spec|
  spec.name          = "kartograph"
  spec.version       = Kartograph::VERSION
  spec.authors       = ["Robert Ross"]
  spec.email         = ["rross@digitalocean.com"]
  spec.summary       = %q{Short Summary}
  spec.description   = %q{Short Description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
end
