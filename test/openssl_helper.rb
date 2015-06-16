require File.expand_path('../test_helper', __FILE__)

module OpenSSLHelper
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

  # Digital Signature Standard counts as a Digest but it uses asymmetric keys; not good for our
  # purposes! Find digest-classes that are actually digests by trying to construct an HMAC with
  # them.
  all_digests = OpenSSL::Digest.constants.map { |c| OpenSSL::Digest.const_get(c) }.
      select { |c| c.superclass == OpenSSL::Digest && c != OpenSSL::Digest::Digest}.
      map { |c| c.name.split('::').last.to_s.downcase }
  DIGEST_ALGORITHMS = all_digests.select do |d|
    begin
      OpenSSL::HMAC.digest(d, 'xyzzy', 'hallo')
    rescue NotImplementedError, RuntimeError
      # If a "digest" is actually an asymmetric signature algorithm, then:
      #  - JRuby raises NIE
      #  - openssl-ext raises RuntimeError
      # Either way, we omit these digests from the list that we test with
      false
    end
  end
  DIGEST_ALGORITHMS.freeze
end
