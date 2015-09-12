require File.expand_path('../test_helper', __FILE__)

module OpenSSLHelper
  algorithms = OpenSSL::Cipher.ciphers

  case RUBY_PLATFORM.to_sym
  when :java
    security_class = java.lang.Class.for_name('javax.crypto.JceSecurity')
    restricted_field = security_class.get_declared_field('isRestricted')
    restricted_field.accessible = true
    restricted_field.set(nil, false)

    # If key length is less than 24 bytes:
    #   OpenSSL::Cipher::CipherError: key length too short
    #
    # If key length is 24 bytes or more:
    #   OpenSSL::Cipher::CipherError: DES key too long - should be 8 bytes:
    #     possibly you need to install Java Cryptography Extension (JCE)
    #     Unlimited Strength Jurisdiction Policy Files for your JRE
    algorithms -= %w(des-ede3 DES-EDE3)
  else
    algorithms &= %x(openssl list-cipher-commands).split
  end

  ALGORITHMS = algorithms.freeze
end
