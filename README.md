# Encryptor

[![Build Status](https://secure.travis-ci.org/attr-encrypted/encryptor.svg)](https://travis-ci.org/attr-encrypted/encryptor) [![Code Climate](https://codeclimate.com/github/attr-encrypted/encryptor/badges/gpa.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Coverage](https://codeclimate.com/github/attr-encrypted/encryptor/badges/coverage.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Gem Version](https://badge.fury.io/rb/encryptor.svg)](http://badge.fury.io/rb/encryptor)

A simple wrapper for the standard Ruby OpenSSL library

### Installation

```bash
gem install encryptor
```

### Usage

#### Basic

Encryptor uses the AES-256-GCM algorithm by default to encrypt strings securely.

The best example is:

```ruby
cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt
secret_key = cipher.random_key # Insures that the key is the correct length respective to the algorithm used.
iv = cipher.random_iv # Insures that the IV is the correct length respective to the algorithm used.
encrypted_value = Encryptor.encrypt(value: 'some string to encrypt', key: secret_key, iv: iv)
decrypted_value = Encryptor.decrypt(value: encrypted_value, key: secret_key, iv: iv)
```

A slightly easier example is:

```ruby
require 'securerandom'
secret_key = SecureRandom.random_bytes(32) # The length in bytes must be equal to or greater than the algorithm bit length.
iv = SecureRandom.random_bytes(12) # Recomended length for AES-###-GCM algorithm. https://tools.ietf.org/html/rfc5084#section-3.2
encrypted_value = Encryptor.encrypt(value: 'some string to encrypt', key: secret_key, iv: iv)
decrypted_value = Encryptor.decrypt(value: encrypted_value, key: secret_key, iv: iv)
```

**NOTE: It is imperative that you use a unique IV per each string and encryption key combo; a nonce as the IV.**
See [RFC 5084](https://tools.ietf.org/html/rfc5084#section-1.5) for more details.

The value to encrypt or decrypt may also be passed as the first option if you'd prefer.

```ruby
encrypted_value = Encryptor.encrypt('some string to encrypt', key: secret_key, iv: iv)
decrypted_value = Encryptor.decrypt(encrypted_value, key: secret_key, iv: iv)
```

You may also pass an `:algorithm` option, though this is not required.

```ruby
Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: 'some default secret key', iv: iv)
```

#### Strings

Older versions of Encryptor added `encrypt` and `decrypt` methods to `String` objects for your convenience. However, this behavior has been removed to avoid polluting Ruby's core String class. The Encryptor::String module remains within this gem to allow users of this feature to implement it themselves. These `encrypt` and `decrypt` methods accept the same arguments as the associated ones in the `Encryptor` module. They're nice when you set the default options in the `Encryptor.default_options attribute.` For example:

```ruby
require 'encryptor/string'
String.include Encryptor::String
Encryptor.default_options.merge!(key: 'some default secret key', iv: iv)
credit_card = 'xxxx xxxx xxxx 1234'
encrypted_credit_card = credit_card.encrypt
```

There's also `encrypt!` and `decrypt!` methods that replace the contents of a string with the encrypted or decrypted version of itself.

### Algorithms

To view a list of all cipher algorithms that are supported on your platform, run the following code in your favorite Ruby REPL:

```ruby
require 'openssl'
puts OpenSSL::Cipher.ciphers
```

The supported ciphers will vary depending on the version of OpenSSL that was used to compile your version of Ruby. However, the following ciphers are typically supported:

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

NOTE: Some ciphers may not be supported by Ruby. Additionally, Ruby compiled with OpenSSL >= v1.0.1 will include AEAD ciphers, ie., aes-256-gcm.

### Notes on patches/pull requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it: this is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history: if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull).
* Send me a pull request: bonus points for topic branches.

