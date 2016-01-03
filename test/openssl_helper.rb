module OpenSSLHelper
  # For test debugging
  puts "OpenSSL Version: #{OpenSSL::OPENSSL_VERSION}"

  ALGORITHMS = OpenSSL::Cipher.ciphers

  case RUBY_PLATFORM.to_sym
  when :java
    security_class = java.lang.Class.for_name('javax.crypto.JceSecurity')
    restricted_field = security_class.get_declared_field('isRestricted')
    restricted_field.accessible = true
    restricted_field.set(nil, false)

    # if key length is less than 24 bytes:
    # OpenSSL::Cipher::CipherError: key length too short
    # if key length is 24 bytes or more:
    # OpenSSL::Cipher::CipherError: DES key too long - should be 8 bytes: possibly you need to install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files for your JRE
    ALGORITHMS -= %w(des-ede3 DES-EDE3)
  else
    ALGORITHMS &= %x(openssl list-cipher-commands).split
  end

  ALGORITHMS.freeze

  AUTHENTICATED_ENCRYPTION_ALGORITHMS = ['aes-128-gcm','aes-192-gcm','aes-256-gcm']
end
