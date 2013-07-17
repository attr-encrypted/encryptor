require File.expand_path('../test_helper', __FILE__)

# Test ensures that values stored by previous versions of the gem will
# roundtrip and decrypt correctly in this and future versions. This is important
# for data stored in databases and allows consumers of the gem to upgrade with
# confidence in the future.
#
class CompatibilityTest < Test::Unit::TestCase
  ALGORITHM = 'aes-256-cbc'

  def self.base64_encode(value)
    [value].pack('m').strip
  end

  def self.base64_decode(value)
    value.unpack('m').first
  end

  if OpenSSL::Cipher.ciphers.include?(ALGORITHM)
    def test_encrypt_with_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      result = Encryptor.encrypt(
        :algorithm => ALGORITHM,
        :value => 'my-fixed-input',
        :key => key,
        :iv => iv
      )
      assert_equal 'nGuyGniksFXnMYj/eCxXKQ==', self.class.base64_encode(result)
    end

    def test_encrypt_without_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      result = Encryptor.encrypt(
        :algorithm => ALGORITHM,
        :value => 'my-fixed-input',
        :key => key
      )
      assert_equal 'XbwHRMFWqR5M80kgwRcEEg==', self.class.base64_encode(result)
    end

    def test_decrypt_with_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      result = Encryptor.decrypt(
        :algorithm => ALGORITHM,
        :value => self.class.base64_decode('nGuyGniksFXnMYj/eCxXKQ=='),
        :key => key,
        :iv => iv
      )
      assert_equal 'my-fixed-input', result
    end

    def test_decrypt_without_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      result = Encryptor.decrypt(
        :algorithm => ALGORITHM,
        :value => self.class.base64_decode('XbwHRMFWqR5M80kgwRcEEg=='),
        :key => key
      )
      assert_equal 'my-fixed-input', result
    end

    def test_encrypt_with_iv_and_salt
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      salt = 'my-fixed-salt'
      result = Encryptor.encrypt(
        :algorithm => ALGORITHM,
        :value => 'my-fixed-input',
        :key => key,
        :iv => iv,
        :salt => salt
      )
      assert_equal 'DENuQSh9b0eW8GN3YLzLGw==', self.class.base64_encode(result)
    end

    def test_decrypt_with_iv_and_salt
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      salt = 'my-fixed-salt'
      result = Encryptor.decrypt(
        :algorithm => ALGORITHM,
        :value => self.class.base64_decode('DENuQSh9b0eW8GN3YLzLGw=='),
        :key => key,
        :iv => iv,
        :salt => salt
      )
      assert_equal 'my-fixed-input', result
    end
  end
end

