# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'encryptor/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'encryptor2'
  s.version  = Encryptor::Version
  s.date     = Date.today
  s.platform = Gem::Platform::RUBY

  s.summary     = 'A simple wrapper for the standard ruby OpenSSL library'
  s.description = 'A simple wrapper for the standard ruby OpenSSL library to encrypt and decrypt strings'

  s.author   = 'Daniel Palacio'
  s.email    = 'danpal@gmail.com'
  s.homepage = 'http://github.com/danpal/encryptor'

  s.require_paths = ['lib']

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  
end
