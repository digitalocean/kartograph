# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kartograph/version'

Gem::Specification.new do |spec|
  spec.name          = "kartograph"
  spec.version       = Kartograph::VERSION
  spec.authors       = ["DigitalOcean API Engineering team"]
  spec.email         = ["api-engineering@digitalocean.com"]
  spec.summary       = %q{Kartograph makes it easy to generate and convert JSON. It's intention is to be used for API clients.}
  spec.description   = %q{Kartograph makes it easy to generate and convert JSON. It's intention is to be used for API clients.}
  spec.homepage      = "https://github.com/digitalocean/kartograph"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", [">= 12.3.3", "< 13.0.0"]
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "pry"
end
