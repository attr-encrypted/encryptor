require 'openssl'

module Huberry
  module Encryptor
    # The default algorithm to use if one is not explicitly passed as an option to the <tt>encrypt</tt> or <tt>decrypt</tt> methods
    #
    # Defaults to 'aes-256-cbc'
    #
    # Run 'openssl list-cipher-commands' in your terminal to view a list all cipher algorithms that are supported on your platform
    class << self; attr_accessor :default_algorithm; end
    self.default_algorithm = 'aes-256-cbc'
    
    # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt>
    #
    # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
    #
    # Example
    #
    #   encrypted_value = Huberry::Encryptor.encrypt(:value => 'some string to encrypt', :key => 'some secret key')
    def self.encrypt(options)
      crypt :encrypt, options
    end
    
    # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt>
    #
    # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
    #
    # Example
    #
    #   decrypted_value = Huberry::Encryptor.decrypt(:value => 'some encrypted string', :key => 'some secret key')
    def self.decrypt(options)
      crypt :decrypt, options
    end
    
    protected
    
      def self.crypt(cipher_method, options = {})
        cipher = OpenSSL::Cipher::Cipher.new(options[:algorithm] || default_algorithm)
        cipher.send(cipher_method)
        if options[:iv]
          cipher.key = options[:key]
          cipher.iv = options[:iv]
        else
          cipher.pkcs5_keyivgen(options[:key])
        end
        result = cipher.update(options[:value])
        result << cipher.final
      end
  end
end