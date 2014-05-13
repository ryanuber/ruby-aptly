lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aptly/version'

Gem::Specification.new do |s|
  files           = Dir.glob('**/*').reject { |f| File.directory? f }
  s.name          = 'aptly'
  s.version       = Aptly::VERSION
  s.summary       = 'Interact with aptly'
  s.description   = 'Wrapper for managing deb package repositories with aptly'
  s.authors       = 'Ryan Uber'
  s.email         = 'ru@ryanuber.com'
  s.files         = files.grep(/^(lib|bin)/)
  s.homepage      = 'https://github.com/ryanuber/ruby-aptly'
  s.license       = 'Apache 2.0'
  s.test_files    = files.grep(/^spec/)
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'
end
