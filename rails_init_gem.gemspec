# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_init_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_init_gem"
  spec.version       = RailsInitGem::VERSION
  spec.authors       = ["Rodrigo Riskalla Leal"]
  spec.email         = ["rodrigo.riskalla.leal@usp.br"]
  spec.summary       = %q{Generates a initial application.}
  spec.description   = %q{Uses lots of Gems to create a functioning application ready for improvements.}
  spec.homepage      = "https://github.com/ziongh/rails_init_gem"
  spec.license       = "Apache v2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
