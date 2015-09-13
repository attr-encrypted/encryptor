require 'openssl'

module Encryptor
  # The default options to use when calling the <tt>encrypt</tt>
  # and <tt>decrypt</tt> methods
  #
  # Defaults:
  #
  #   {
  #     :algorithm => 'aes-256-cbc',
  #     :hmac_iterations => 2000,
  #   }
  #
  # Run 'openssl list-cipher-commands' in your shell to view the
  # list of cipher algorithms that are supported on your platform
  def self.default_options
    @default_options ||= {
      :algorithm => 'aes-256-cbc',
      :hmac_iterations => 2000,
    }
  end

  class Cipher
    def self.process(method, value, options = {}, &block)
      if value.is_a?(Hash)
        options = value
        value = options.fetch(:value)
      end

      new(options).send(method, value, &block)
    end

    def initialize(options)
      @options = Encryptor.default_options.merge(options)
    end

    def encrypt(value, &block)
      cipher = openssl.tap(&:encrypt)
      process(cipher, value, &block)
    end

    def decrypt(value, &block)
      cipher = openssl.tap(&:decrypt)
      process(cipher, value, &block)
    end

    private

    def openssl
      OpenSSL::Cipher::Cipher.new(algorithm)
    end

    def process(cipher, value)
      if iv
        cipher.iv = iv
      else
        cipher.pkcs5_keyivgen(key)
      end

      if salt
        # Use an explicit salt which can be persisted into a database on
        # a per-column basis, for example. This is the preferred and more
        # secure mode of operation.
        hmac = [key, salt, hmac_iterations, cipher.key_len]
        cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(*hmac)
      elsif iv
        # Use a non-salted cipher. This behavior is retained for backwards
        # compatibility. This mode is not secure and new deployments should
        # use the :salt options wherever possible.
        cipher.key = key
      end

      if block_given?
        options = @options.merge(:value => value)
        yield(cipher, options)
      end

      cipher.update(value).concat(cipher.final)
    end

    def algorithm
      @options.fetch(:algorithm)
    end

    def hmac_iterations
      @options.fetch(:hmac_iterations)
    end

    def iv
      @options[:iv]
    end

    def key
      @options[:key].to_s.tap do |key|
        raise ArgumentError, 'must specify a :key' if key.empty?
      end
    end

    def salt
      @options[:salt]
    end
  end
end
