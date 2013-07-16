require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../openssl_helper', __FILE__)

# Tests for legacy (non-salted) encryption mode
#
class LegacyEncryptorTest < Test::Unit::TestCase

  key = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  iv = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  original_value = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = Encryptor.encrypt(:value => original_value, :key => key, :iv => iv, :algorithm => algorithm)
    encrypted_value_without_iv = Encryptor.encrypt(:value => original_value, :key => key, :algorithm => algorithm)

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_with_iv" do
      assert_not_equal original_value, encrypted_value_with_iv
      assert_not_equal encrypted_value_without_iv, encrypted_value_with_iv
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_with_iv, :key => key, :iv => iv, :algorithm => algorithm)
    end

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_without_iv" do
      assert_not_equal original_value, encrypted_value_without_iv
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_without_iv, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_with_iv, Encryptor.encrypt(original_value, :key => key, :iv => iv, :algorithm => algorithm)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_without_iv, Encryptor.encrypt(original_value, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_with_iv, :key => key, :iv => iv, :algorithm => algorithm)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_without_iv, :key => key, :algorithm => algorithm)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal encrypted_value_with_iv, original_value.encrypt(:key => key, :iv => iv, :algorithm => algorithm)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal encrypted_value_without_iv, original_value.encrypt(:key => key, :algorithm => algorithm)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal original_value, encrypted_value_with_iv.decrypt(:key => key, :iv => iv, :algorithm => algorithm)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal original_value, encrypted_value_without_iv.decrypt(:key => key, :algorithm => algorithm)
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(:key => key, :iv => iv, :algorithm => algorithm)
      assert_equal original_value.encrypt(:key => key, :iv => iv, :algorithm => algorithm), original_value_dup
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(:key => key, :algorithm => algorithm)
      assert_equal original_value.encrypt(:key => key, :algorithm => algorithm), original_value_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      encrypted_value_with_iv_dup = encrypted_value_with_iv.dup
      encrypted_value_with_iv_dup.decrypt!(:key => key, :iv => iv, :algorithm => algorithm)
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

  def test_should_have_a_default_algorithm
    assert !Encryptor.default_options[:algorithm].nil?
    assert !Encryptor.default_options[:algorithm].empty?
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

