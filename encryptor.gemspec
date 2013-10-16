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

  s.authors   = ['Sean Huber', 'S. Brent Faulkner', 'William Monk']
  s.email    = ['shuber@huberry.com', 'sbfaulkner@gmail.com', 'billy.monk@gmail.com']
  s.homepage = 'http://github.com/attr-encrypted/encryptor'

  s.require_paths = ['lib']

  s.files      = Dir['{bin,lib}/**/*'] + %w(MIT-LICENSE Rakefile README.md)
  s.test_files = Dir['test/**/*']

  s.add_development_dependency('rake', '0.9.2.2')

  if RUBY_VERSION < '1.9.3'
    s.add_development_dependency('rcov')
  else
    s.add_development_dependency('simplecov')
    s.add_development_dependency('simplecov-rcov')
  end
end
