## Encryptor  [![Build Status](https://travis-ci.org/attr-encrypted/encryptor.png?branch=master)](https://travis-ci.org/attr-encrypted/encryptor)

A simple wrapper for the standard Ruby OpenSSL library

Intended to be used by a future version of `http://github.com/shuber/attr_encrypted` to easily encrypt/decrypt attributes in any Ruby class or model.

### Installation

```bash
gem install encryptor
```

### Usage

#### Basic

Encryptor uses the AES-256-CBC algorithm by default to encrypt strings securely. You are strongly advised to use both an initialization vector (via the `:iv` option) and a salt (via the `:salt` option) to perform this encryption as securely as possible. Specifying only an `:iv` option without `:salt` is not recommended but is supported as part of a "compatibility mode" to support clients built using older versions of this gem.

The best example is:

```ruby
salt = Time.now.to_i.to_s
secret_key = 'secret'
iv = OpenSSL::Cipher::Cipher.new('aes-256-cbc').random_iv
encrypted_value = Encryptor.encrypt('some string to encrypt', :key => secret_key, :iv => iv, :salt => salt)
decrypted_value = Encryptor.decrypt(encrypted_value, :key => secret_key, :iv => iv, :salt => salt)
```

The value to encrypt or decrypt may also be passed as the :value option if you'd prefer.

```ruby
encrypted_value = Encryptor.encrypt(:value => 'some string to encrypt', :key => secret_key, :iv => iv, :salt => salt)
decrypted_value = Encryptor.decrypt(:value => encrypted_value, :key => secret_key, :iv => iv, :salt => salt)
```

**You may also skip the salt and the IV if you like. Do so at your own risk!**

```ruby
encrypted_value = Encryptor.encrypt(:value => 'some string to encrypt', :key => 'secret')
decrypted_value = Encryptor.decrypt(:value => encrypted_value, :key => 'secret')
```

You may also pass an `:algorithm` option, though this is not required.

```ruby
Encryptor.default_options.merge!(:algorithm => 'aes-128-cbc', :key => 'some default secret key', :iv => iv, :salt => salt)
```

#### Strings

Encryptor adds `encrypt` and `decrypt` methods to `String` objects for your convenience. These two methods accept the same arguments as the associated ones in the `Encryptor` module. They're nice when you set the default options in the `Encryptor.default_options attribute.` For example:

```ruby
Encryptor.default_options.merge!(:key => 'some default secret key', :iv => iv, :salt => salt)
credit_card = 'xxxx xxxx xxxx 1234'
encrypted_credit_card = credit_card.encrypt
```

There's also `encrypt!` and `decrypt!` methods that replace the contents of a string with the encrypted or decrypted version of itself.

### Algorithms

Run `openssl list-cipher-commands` in your terminal to view a list of all cipher algorithms that are supported on your platform. Typically, this will include the following:

    aes-128-cbc
    aes-128-ecb
    aes-192-cbc
    aes-192-ecb
    aes-256-cbc
    aes-256-ecb
    bf
    bf-cbc
    bf-cfb
    bf-ecb
    bf-ofb
    cast
    cast-cbc
    cast5-cbc
    cast5-cfb
    cast5-ecb
    cast5-ofb
    des
    des-cbc
    des-cfb
    des-ecb
    des-ede
    des-ede-cbc
    des-ede-cfb
    des-ede-ofb
    des-ede3
    des-ede3-cbc
    des-ede3-cfb
    des-ede3-ofb
    des-ofb
    des3
    desx
    idea
    idea-cbc
    idea-cfb
    idea-ecb
    idea-ofb
    rc2
    rc2-40-cbc
    rc2-64-cbc
    rc2-cbc
    rc2-cfb
    rc2-ecb
    rc2-ofb
    rc4
    rc4-40

Note that some ciphers may not be supported by Ruby.

### Notes on patches/pull requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it: this is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history: if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull).
* Send me a pull request: bonus points for topic branches.

