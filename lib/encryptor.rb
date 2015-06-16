require 'openssl'
require 'encryptor/string'

String.send(:include, Encryptor::String)

# A simple wrapper for the standard OpenSSL library
module Encryptor
  autoload :Version, 'encryptor/version'

  extend self

  # The default options to use when calling the <tt>encrypt</tt> and <tt>decrypt</tt> methods;
  # specifies safe default algorithms, but the caller must provide keys
  #
  # Defaults to { :algorithm => 'aes-256-cbc', :hmac_algorithm => 'sha256' }
  #
  # Run 'openssl list-cipher-commands' in your terminal to view a list all cipher algorithms that are supported on your platform
  def default_options
    @default_options ||= {
        :algorithm => 'aes-256-cbc',
        :hmac_algorithm => 'sha256',
    }
  end

  # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt>,  <tt>:algorithm</tt>, <tt>:hmac_algorithm</tt>, or <tt>:hmac_key</tt>
  #
  # Example
  #
  #   encrypted_value = Encryptor.encrypt(:value => 'some string to encrypt', :key => 'some secret key')
  #   # or, passing the plaintext positionally
  #   encrypted_value = Encryptor.encrypt('some string to encrypt', :key => 'some secret key')
  #   # or, asking for integrity in addition to secrecy
  #   encrypted_value = Encryptor.encrypt('some string to encrypt', :key => 'some secret key', :hmac_key => 'another secret key')
  def encrypt(*args, &block)
    crypt :encrypt, *args, &block
  end

  # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt>, <tt>:hmac_algorithm</tt>, or <tt>:hmac_key</tt>
  #
  # Raises OpenSSL::HMACError if an integrity check fails
  #
  # Example
  #
  #   decrypted_value = Encryptor.decrypt(:value => 'some encrypted string', :key => 'some secret key')
  #   # or, passing the ciphertext positionally
  #   decrypted_value = Encryptor.decrypt('some encrypted string', :key => 'some secret key')
  #   # or, verifying integrity in addition to decrypting
  #   decrypted_value = Encryptor.decrypt('some encrypted string', :key => 'some secret key', :hmac_key => 'another secret key')
  def decrypt(*args, &block)
    crypt :decrypt, *args, &block
  end

  protected

  def crypt(cipher_method, *args) #:nodoc:
    options = default_options.merge(:value => args.first).merge(args.last.is_a?(Hash) ? args.last : {})
    raise ArgumentError.new('must specify a :key') if options[:key].to_s.empty?
    cipher = OpenSSL::Cipher::Cipher.new(options[:algorithm])
    cipher.send(cipher_method)
    if options[:iv]
      cipher.iv = options[:iv]
      if options[:salt].nil?
        # Use a non-salted cipher.
        # This behaviour is retained for backwards compatibility. This mode
        # is not secure and new deployments should use the :salt options
        # wherever possible.
        cipher.key = options[:key]
      else
        # Use an explicit salt (which can be persisted into a database on a
        # per-column basis, for example). This is the preferred (and more
        # secure) mode of operation.
        cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(options[:key], options[:salt], 2000, cipher.key_len)
      end
    else
      cipher.pkcs5_keyivgen(options[:key])
    end

    yield cipher, options if block_given?

    # NB the method's return value is determined by the last expression in each conditional!
    if (hmac_key = options[:hmac_key])
      digest   = OpenSSL::Digest.new(options[:hmac_algorithm])
      if cipher_method == :decrypt
        # verify hmac
        hmac = options[:value][0.. digest.length-1]
        ciphertext = options[:value][digest.length..-1]
        # hash the cipher-text using :hmac_algorithm
        integrity_check = OpenSSL::HMAC.digest(digest, hmac_key, ciphertext)
        raise OpenSSL::HMACError.new('integrity check failed') if hmac != integrity_check
        cipher.update(ciphertext) << cipher.final
      else
        # create hmac
        ciphertext = cipher.update(options[:value]) << cipher.final
        integrity_check = OpenSSL::HMAC.digest(digest, hmac_key, ciphertext)
        integrity_check << ciphertext
      end
    else
      cipher.update(options[:value]) << cipher.final
    end
  end
end
