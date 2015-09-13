require File.expand_path('../lib/encryptor/version', __FILE__)

Gem::Specification.new do |s|
  s.authors               = ['Sean Huber', 'S. Brent Faulkner', 'William Monk']
  s.email                 = %w(sean@shuber.io sbfaulkner@gmail.com billy.monk@gmail.com)
  s.extra_rdoc_files      = %w(MIT-LICENSE)
  s.files                 = `git ls-files`.split("\n")
  s.homepage              = 'https://github.com/attr-encrypted/encryptor'
  s.license               = 'MIT'
  s.name                  = 'encryptor'
  s.rdoc_options          = %w(--charset=UTF-8 --inline-source --line-numbers --main README.md)
  s.require_paths         = %w(lib)
  s.required_ruby_version = '>= 1.9.3'
  s.summary               = 'A simple wrapper for the standard ruby OpenSSL library'
  s.test_files            = `git ls-files -- test/*`.split("\n")
  s.version               = Encryptor::Version

  s.add_development_dependency('minitest')
  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-rcov')
end
