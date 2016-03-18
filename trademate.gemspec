# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trademate/version'

Gem::Specification.new do |spec|
  spec.name          = 'trademate'
  spec.version       = Trademate::VERSION
  spec.authors       = ['Matthias Grosser']
  spec.email         = ['mtgrosser@gmx.net']

  spec.summary       = %q{Ruby wrapper for the trademate API}
  spec.description   = %q{Ruby wrapper for the trademate API}
  spec.homepage      = 'https://github.com/trademate/trademate-ruby'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oo_auth'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'byebug'
end
