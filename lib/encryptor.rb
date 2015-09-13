require 'encryptor/cipher'
require 'encryptor/string'
require 'encryptor/version'

String.send(:include, Encryptor::String)

# A simple wrapper for the standard OpenSSL library
module Encryptor
  extend self

  # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Examples
  #
  #   Encryptor.encrypt('some string to encrypt', :key => 'some secret key')
  #
  #   Encryptor.encrypt(
  #     :value => 'some string to encrypt',
  #     :key => 'some secret key'
  #   )
  def encrypt(value, options = {}, &block)
    Cipher.process(:encrypt, value, options, &block)
  end

  # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Examples
  #
  #   Encryptor.decrypt('some encrypted string', :key => 'some secret key')
  #
  #   Encryptor.decrypt(
  #     :value => 'some encrypted string',
  #     :key => 'some secret key'
  #   )
  def decrypt(value, options = {}, &block)
    Cipher.process(:decrypt, value, options, &block)
  end
end
