require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../openssl_helper', __FILE__)

# Tests for new preferred salted encryption mode
#
class EncryptorTest < Test::Unit::TestCase

  key = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  iv = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  salt = Time.now.to_i.to_s
  original_value = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = Encryptor.encrypt(:value => original_value, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    encrypted_value_without_iv = Encryptor.encrypt(:value => original_value, :key => key, :algorithm => algorithm)

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_with_iv" do
      assert_not_equal original_value, encrypted_value_with_iv
      assert_not_equal encrypted_value_without_iv, encrypted_value_with_iv
      assert_equal original_value, Encryptor.decrypt(:value => encrypted_value_with_iv, :key => key, :iv => iv, :salt => salt, :algorithm => algorithm)
    end

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_without_iv" do
      assert_not_equal original_value, encrypted_value_without_iv
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

  def test_should_raise_a_descriptive_error_when_given_a_bad_key
    key = '04fe53f20e0ae210efd0f2af0c86408bbf7ed96446b7ba363e1cc9e087704a74'
    salt = '06fdd104c5db3df7'
    original_value = 'Foo all the bars!'
    encrypted_value = Encryptor.encrypt(:value => original_value, :key => key, :salt => salt)

    assert_raises Encryptor::Errors::BadDecryptError do
      Encryptor.decrypt(:value => encrypted_value, :key => 'invalid_key', :salt => salt)
    end
  end

  def test_should_raise_a_descriptive_error_when_final_block_is_invalid
    assert_raises Encryptor::Errors::BlockLengthError do
      Encryptor.decrypt({
        value: 'this is not the right number of bytes',
        key: '04fe53f20e0ae210efd0f2af0c86408bbf7ed96446b7ba363e1cc9e087704a74'
      })
    end
  end

  def test_should_raise_a_descriptive_error_when_iv_is_too_short
    assert_raises Encryptor::Errors::IVLengthError do
      Encryptor.encrypt({
        value: 'this value does not matter but is invalid anyway',
        iv: 'short iv',
        key: '04fe53f20e0ae210efd0f2af0c86408bbf7ed96446b7ba363e1cc9e087704a74'
      })
    end

    assert_raises Encryptor::Errors::IVLengthError do
      Encryptor.decrypt({
        value: 'this value does not matter but is invalid anyway',
        iv: 'short iv',
        key: '04fe53f20e0ae210efd0f2af0c86408bbf7ed96446b7ba363e1cc9e087704a74'
      })
    end
  end
end
