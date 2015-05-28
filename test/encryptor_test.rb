require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../openssl_helper', __FILE__)

# Tests for new preferred salted encryption mode
#
class EncryptorTest < Minitest::Test

  key = SecureRandom.random_bytes(64)
  iv = SecureRandom.random_bytes(64)
  salt = Time.now.to_i.to_s
  original_value = SecureRandom.random_bytes(64)
  hmac_key = SecureRandom.random_bytes(64)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = Encryptor.encrypt(:value => original_value, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    encrypted_value_without_iv = Encryptor.encrypt(:value => original_value, :key => key, :algorithm => algorithm)

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_with_iv" do
      refute_equal original_value, encrypted_value_with_iv
      refute_equal encrypted_value_without_iv, encrypted_value_with_iv
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_with_iv, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_without_iv" do
      refute_equal original_value, encrypted_value_without_iv
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_without_iv, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_with_iv, Encryptor.encrypt(original_value, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_without_iv, Encryptor.encrypt(original_value, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_with_iv, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_without_iv, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal encrypted_value_with_iv, original_value.encrypt(:key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal encrypted_value_without_iv, original_value.encrypt(:key => key, :algorithm => algorithm)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal original_value, encrypted_value_with_iv.decrypt(:key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal original_value, encrypted_value_without_iv.decrypt(:key => key, :algorithm => algorithm)
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(:key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
      assert_equal original_value.encrypt(:key => key, :iv => iv, :salt => salt, :algorithm => algorithm), original_value_dup
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(:key => key, :algorithm => algorithm)
      assert_equal original_value.encrypt(:key => key, :algorithm => algorithm), original_value_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      encrypted_value_with_iv_dup = encrypted_value_with_iv.dup
      encrypted_value_with_iv_dup.decrypt!(:key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
      assert_equal original_value, encrypted_value_with_iv_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      encrypted_value_without_iv_dup = encrypted_value_without_iv.dup
      encrypted_value_without_iv_dup.decrypt!(:key => key, :algorithm => algorithm)
      assert_equal original_value, encrypted_value_without_iv_dup
    end
  end

  define_method 'test_should_use_the_default_algorithm_if_one_is_not_specified' do
    assert_equal Encryptor.encrypt(:value => original_value, :key => key, :algorithm => Encryptor.default_options[:algorithm]), Encryptor.encrypt(:value => original_value, :key => key)
  end

  OpenSSLHelper::DIGEST_ALGORITHMS.each do |digest_algorithm|
    define_method "test_should_crypt_with_the_#{digest_algorithm}_hmac_algorithm" do
      encrypted_value_with_hmac = Encryptor.encrypt(:value => original_value, :key => key, :salt => salt, :hmac_algorithm => digest_algorithm, :hmac_key => hmac_key)
      encrypted_value_without_hmac = Encryptor.encrypt(:value => original_value, :key => key, :salt => salt)
      # verify we can round-trip encrypt and decrypt something using :hmac_algorithm and :hmac_key
      # verify that ciphertext w/integrity check is NOT same as ciphertext without
      refute_equal original_value, encrypted_value_with_hmac
      refute_equal encrypted_value_without_hmac, encrypted_value_with_hmac
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_with_hmac, :key => key, :salt => salt, :hmac_algorithm => digest_algorithm, :hmac_key => hmac_key)
    end

    define_method "test_should_fail_decrypt_with_the_#{digest_algorithm}_hmac_algorithm_when_ciphertext_is_changed" do
      encrypted_value_with_hmac = Encryptor.encrypt(:value => original_value, :key => key, :salt => salt, :hmac_algorithm => digest_algorithm, :hmac_key => hmac_key)

      modified_encrypted_value = encrypted_value_with_hmac
      i =  encrypted_value_with_hmac.length
      modified_encrypted_value[i/2] = (modified_encrypted_value[i/2] == 'a') ? 'z' : 'a'

      assert_raises(OpenSSL::HMACError) do
        Encryptor.decrypt(:value => encrypted_value_with_hmac, :key => key, :salt => salt, :hmac_algorithm => digest_algorithm, :hmac_key => hmac_key)
      end
    end
  end

  def test_should_have_a_default_algorithm
    assert !Encryptor.default_options[:algorithm].nil?
    assert !Encryptor.default_options[:algorithm].empty?
  end

  def test_should_have_a_default_hmac_algorithm
    assert !Encryptor.default_options[:hmac_algorithm].nil?
    assert !Encryptor.default_options[:hmac_algorithm].empty?
    assert Encryptor.default_options[:hmac_key].nil?
  end

  def test_should_raise_argument_error_if_key_is_not_specified
    assert_raises(ArgumentError) { Encryptor.encrypt('some value') }
    assert_raises(ArgumentError) { Encryptor.decrypt('some encrypted string') }
    assert_raises(ArgumentError) { Encryptor.encrypt('some value', :key => '') }
    assert_raises(ArgumentError) { Encryptor.decrypt('some encrypted string', :key => '') }
  end

  def test_should_yield_block_with_cipher_and_options
    called = false
    Encryptor.encrypt('some value', :key => 'some key') { |cipher, options| called = true }
    assert called
  end

end

