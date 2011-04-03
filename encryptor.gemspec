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

  s.author   = 'Sean Huber'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/shuber/encryptor'

  s.require_paths = ['lib']

  s.files      = Dir['{bin,lib}/**/*'] + %w(MIT-LICENSE Rakefile README.rdoc)
  s.test_files = Dir['test/**/*']
end