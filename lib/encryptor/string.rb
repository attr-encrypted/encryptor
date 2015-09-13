module Encryptor
  # Adds <tt>encrypt</tt> and <tt>decrypt</tt> methods to strings
  module String
    include Encryptor

    # Returns a new string containing the encrypted version of itself
    def encrypt(options = {}, &block)
      super(self, options, &block)
    end

    # Replaces the contents of a string with the encrypted version of itself
    def encrypt!(options = {}, &block)
      encrypted = encrypt(options, &block)
      replace(encrypted)
    end

    # Returns a new string containing the decrypted version of itself
    def decrypt(options = {}, &block)
      super(self, options, &block)
    end

    # Replaces the contents of a string with the decrypted version of itself
    def decrypt!(options ={}, &block)
      decrypted = decrypt(options, &block)
      replace(decrypted)
    end
  end
end
