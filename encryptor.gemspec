# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'encryptor/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'encryptor'
  s.version  = Encryptor::Version
  s.date     = Date.today
  s.platform = Gem::Platform::RUBY

  s.summary     = 'A simple wrapper for the standard ruby OpenSSL library'
  s.description = 'A simple wrapper for the standard ruby OpenSSL library to encrypt and decrypt strings'

  s.authors   = ['Sean Huber', 'S. Brent Faulkner', 'William Monk', 'Stephen Aghaulor']
  s.email    = ['sean@shuber.io', 'sbfaulkner@gmail.com', 'billy.monk@gmail.com', 'saghaulor@gmail.com']
  s.homepage = 'http://github.com/attr-encrypted/encryptor'
  s.license = 'MIT'
  s.rdoc_options = %w(--charset=UTF-8 --inline-source --line-numbers --main README.md)

  s.require_paths = ['lib']

  s.files      = Dir['{bin,lib}/**/*'] + %w(MIT-LICENSE Rakefile README.md)
  s.test_files = Dir['test/**/*']

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency('minitest')
  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-rcov')
  s.add_development_dependency('codeclimate-test-reporter')

  s.requirements << 'openssl, >= v1.0.1'
end
