if RUBY_VERSION >= '1.9.3'
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter,
  ]

  SimpleCov.start do
    add_filter 'test'
  end
end

require 'test/unit'
require 'digest/sha2'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'encryptor'