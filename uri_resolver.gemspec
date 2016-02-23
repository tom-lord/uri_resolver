# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uri_resolver/version'

Gem::Specification.new do |spec|
  spec.name          = "uri_resolver"
  spec.version       = UriResolver::VERSION
  spec.authors       = ["Tom Lord"]
  spec.email         = ["tom.lord@comlaude.com"]

  spec.summary       = %q{Like "ping", but better -- especially for new GTLDs}
  spec.homepage      = "https://github.com/tom-lord/uri_resolver"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'httparty'
end
