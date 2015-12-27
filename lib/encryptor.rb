require 'openssl'
require 'encryptor/string'

String.send(:include, Encryptor::String)

# A simple wrapper for the standard OpenSSL library
module Encryptor
  autoload :Version, 'encryptor/version'

  AUTHENTICATED_ENCRYPTION_ALGORITHMS = ['aes-128-gcm','aes-192-gcm','aes-256-gcm']

  extend self

  # The default options to use when calling the <tt>encrypt</tt> and <tt>decrypt</tt> methods
  #
  # Defaults to { :algorithm => 'aes-256-cbc' }
  #
  # Run 'openssl list-cipher-commands' in your terminal to view a list all cipher algorithms that are supported on your platform
  def default_options
    @default_options ||= { algorithm: 'aes-256-cbc', auth_data: '' }
  end

  # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Example
  #
  #   encrypted_value = Encryptor.encrypt(:value => 'some string to encrypt', :key => 'some secret key')
  #   # or
  #   encrypted_value = Encryptor.encrypt('some string to encrypt', :key => 'some secret key')
  def encrypt(*args, &block)
    crypt :encrypt, *args, &block
  end

  # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Example
  #
  #   decrypted_value = Encryptor.decrypt(:value => 'some encrypted string', :key => 'some secret key')
  #   # or
  #   decrypted_value = Encryptor.decrypt('some encrypted string', :key => 'some secret key')
  def decrypt(*args, &block)
    crypt :decrypt, *args, &block
  end

  protected

    def crypt(cipher_method, *args) #:nodoc:
      options = default_options.merge(:value => args.first).merge(args.last.is_a?(Hash) ? args.last : {})
      raise ArgumentError.new('must specify a :key') if options[:key].to_s.empty?
      cipher = OpenSSL::Cipher::Cipher.new(options[:algorithm])
      uses_message_authentication = AUTHENTICATED_ENCRYPTION_ALGORITHMS.include? options[:algorithm]
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
      value = cipher_method == :decrypt && uses_message_authentication ? options[:value][0..-17] : options[:value]
      cipher.auth_tag = options[:value][-16..-1] if uses_message_authentication && cipher_method == :decrypt
      cipher.auth_data = options[:auth_data] if uses_message_authentication
      result = cipher.update(value)
      result << cipher.final
      result << cipher.auth_tag if uses_message_authentication && cipher_method == :encrypt
      result
    end

end
