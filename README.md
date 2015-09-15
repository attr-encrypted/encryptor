# Encryptor

[![Build Status](https://secure.travis-ci.org/attr-encrypted/encryptor.svg)](https://travis-ci.org/attr-encrypted/encryptor) [![Code Climate](https://codeclimate.com/github/attr-encrypted/encryptor/badges/gpa.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Coverage](https://codeclimate.com/github/attr-encrypted/encryptor/badges/coverage.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Gem Version](https://badge.fury.io/rb/encryptor.svg)](http://badge.fury.io/rb/encryptor)

A simple wrapper for the standard Ruby [OpenSSL](http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL.html) library.

Check out [`attr_encrypted`](http://github.com/attr-encrypted/attr_encrypted) for a simple DSL to encrypt and decrypt attributes in any class or model.

```ruby
class User
  attr_encrypted :ssn, :key => "secret key"
end

user = User.new
user.ssn = "1234-1234-1234-1234"
user.encrypted_ssn #=> "\x87\xF8\x14hj\xFFi Q\xC45s\xAC\xEE\x8F\rbs\x85))@\xC7SL\aV\xCB\x00h\xDB\x90"
```

## Installation

```bash
gem install encryptor
```

## Configuration

Update `Encryptor.default_options` to define default encryption settings. An initializer would be a good place for this if you're using Rails e.g. `config/initializers/encryption.rb`.

```ruby
Encryptor.default_options.update(
  # required
  :key => ENV.fetch("ENCRYPTION_KEY"),

  # defaults
  :algorithm => "aes-256-cbc",
  :hmac_iterations => 2000,

  # STRONGLY RECOMMENDED TO OVERRIDE <-----------------(details below)---------------
  :iv => nil,
  :salt => nil
)
```

## Usage

Four new methods have been introduced to `String` objects. All of them accept an optional hash of encryption options which override those in `Encryptor.default_options`.

* `encrypt`
* `encrypt!`
* `decrypt`
* `decrypt!`

```ruby
encrypted = "some sensitive info".encrypt

puts encrypted.inspect
#=> "\xAB\xFCx\xA3\x0E\xBCr\x1A\x12\xD1\xAC\xCB\x14z\x86*\x0F3\xBE\x98\x14\xA9k\nQ\x19\x8F8\xCA\xB2\x8C9"

puts encrypted.decrypt
#=> "some sensitive info"

puts encrypted.decrypt(:key => "bad key")
# raises OpenSSL::Cipher::CipherError: bad decrypt
```

The `encrypt!` and `decrypt!` methods simply [`replace`](http://ruby-doc.org/core-2.2.3/String.html#method-i-replace) the contents of a string with the encrypted or decrypted version of itself.

### You are strongly advised to use both `:iv` & `:salt` options

Performing encryption as **securely as possible** requires specifying an [initialization vector](https://en.wikipedia.org/wiki/Initialization_vector) and a [salt](https://en.wikipedia.org/wiki/Salt_(cryptography)).

Using the `:iv` option without `:salt` is not recommended but is supported as part of a *compatibility mode* for clients built using older versions of this gem.

A best practice example would be:

```ruby
salt = OpenSSL::Random.random_bytes(16)
althorithm = Encryptor.default_options[:algorithm]
iv = OpenSSL::Cipher::Cipher.new(algorithm).random_iv

encrypted = "some string to encrypt".encrypt(:iv => iv, :salt => salt)

puts encrypted.inspect
#=> "\xAB\xFCx\xA3\x0E\xBCr\x1A\x12\xD1\xAC\xCB\x14z\x86*\x0F3\xBE\x98\x14\xA9k\nQ\x19\x8F8\xCA\xB2\x8C9"

# persist encrypted, iv, and salt somewhere then
# restore and decrypt it sometime in the future

decrypted = encrypted.decrypt(:iv => iv, :salt => salt)

puts decrypted.inspect
#=> "some string to encrypt"
```

**You may skip the salt and the IV if you like. Do so at your own risk!**

## Custom cipher configuration using `block` arguments

TODO: describe and demonstrate

## The `Encryptor` module

The `Encryptor` module is a simple wrapper for `encrypt` and `decrypt` which can be mixed into your classes. It provides the following interface:

* `encrypt(value = nil, options = {}, &block)`
* `decrypt(value = nil, options = {}, &block)`

Either `value` or `options[:value]` **must be present** or a `KeyError` will be raised.

This interface allows us to wrap custom behavior around encrypting and decrypting data. For example, let's add support to encrypt and decrypt any Ruby object, not just strings!

```ruby
class MarshalEncryptor
  include Encryptor

  def encrypt(value, options = {})
    value = Marshal.dump(value)
    super
  end

  def decrypt(value, options = {})
    Marshal.load(super)
  end
end

MarshalEncryptor.new.encrypt([1, 2, 3], :key => "secret key")
```

The enhancements made to `String` actually build upon these methods in a similar way:

```ruby
String.class_eval do
  include Encryptor

  def encrypt(options = {}, &block)
    super(self, options, &block)
  end

  def decrypt(options = {}, &block)
    super(self, options, &block)
  end
end
```

The `Encryptor` module also extends itself to make these methods available there as well.

```ruby
encrypted = Encryptor.encrypt(:value => "sensitive data", :key => "secret key")
decrypted = Encryptor.decrypt(encrypted, :key => "secret key")
```

## Algorithms

Run `openssl list-cipher-commands` in your terminal to view a list of all cipher algorithms that are supported on your platform.

Typically, this list will include the following:

```
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
```

Note that some ciphers may not be supported by Ruby.

## API

[YARD Documentation](http://www.rubydoc.info/github/attr-encrypted/encryptor)

* `Encryptor#decrypt`
* `Encryptor#encrypt`
* `String#decrypt`
* `String#decrypt!`
* `String#encrypt`
* `String#encrypt!`

## Testing

```bash
bundle exec rake
```

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with the version or history.
* Send me a pull request. Bonus points for topic branches.

## License

[MIT](https://github.com/attr-encrypted/encryptor/blob/master/MIT-LICENSE) - Copyright © 2011-2015 Sean Huber
