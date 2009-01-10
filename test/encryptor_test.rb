require 'test/unit'
require 'digest/sha2'
require File.dirname(__FILE__) + '/../lib/encryptor'

class EncryptorTest < Test::Unit::TestCase
  
  algorithms = %x(openssl list-cipher-commands).split  
  original_value = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  key = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  iv = Digest::SHA256.hexdigest(([Time.now.to_s] * rand(3)).join)
  
  algorithms.each do |algorithm|
    define_method "test_should_crypt_with_#{algorithm}_algorithm_with_iv" do
      encrypted_value = Huberry::Encryptor.encrypt(:value => original_value, :key => key, :iv => iv, :algorithm => algorithm)
      assert_not_equal original_value, encrypted_value
      assert_not_equal Huberry::Encryptor.encrypt(:value => original_value, :key => key, :algorithm => algorithm), encrypted_value
      assert_equal original_value, Huberry::Encryptor.decrypt(:value => encrypted_value, :key => key, :iv => iv, :algorithm => algorithm)
    end
    
    define_method "test_should_crypt_with_#{algorithm}_algorithm_without_iv" do
      encrypted_value = Huberry::Encryptor.encrypt(:value => original_value, :key => key, :algorithm => algorithm)
      assert_not_equal original_value, encrypted_value
      assert_equal original_value, Huberry::Encryptor.decrypt(:value => encrypted_value, :key => key, :algorithm => algorithm)
    end
  end
  
  define_method 'test_should_have_a_default_algorithm' do
    assert algorithms.include?(Huberry::Encryptor.default_options[:algorithm])
  end
  
  define_method 'test_should_use_the_default_algorithm_if_one_is_not_specified' do
    assert_equal Huberry::Encryptor.encrypt(:value => original_value, :key => key, :algorithm => Huberry::Encryptor.default_options[:algorithm]), Huberry::Encryptor.encrypt(:value => original_value, :key => key)
  end
  
  def test_should_be_able_to_change_the_default_algorithm
    original_algorithm = Huberry::Encryptor.default_options[:algorithm]
    assert_not_equal 'test', original_algorithm
    Huberry::Encryptor.default_options[:algorithm] = 'test'
    assert_equal 'test', Huberry::Encryptor.default_options[:algorithm]
    Huberry::Encryptor.default_options[:algorithm] = original_algorithm
  end
  
end