require File.expand_path('../test_helper', __FILE__)

module OpenSSLHelper
  ALGORITHMS = %x(openssl list-cipher-commands).split & OpenSSL::Cipher.ciphers
end

