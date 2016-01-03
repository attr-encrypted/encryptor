# Encryptor #

## Unreleased ##

* Added support for MRI 2.1, 2.2, 2.3, and Rubinius. (@saghaulor)
* Added support for Authenticated Encryption Authentiation Data (AEAD) via aes-###-gcm. (@saghaulor)
* Changed the defaults to improve security, aes-256-gcm, IV is required. (@saghaulor)
* Added key and IV minimum length validations. (@saghaulor)
* Added insecure_mode option to allow for backwards compatibility for users who didn't use unique IV. (@saghaulor)
* Deprecated using Encryptor without an IV.
* Removed support for MRI 1.9.3 and JRuby (until JRuby supports `auth_data=`, https://github.com/jruby/jruby/issues/3376). (@saghaulor)
* Changed tests to use Minitest. (@saghaulor)
* Changed syntax to use Ruby 1.9+ hash syntax. (@saghaulor)
* Salt will be deprecated in a future release, it remains for backwards compatibility. It's better security to have a unique key per record, however, the cost of PKCS5 is too high to force on to users by default. If users want a unique key per record they can implement it in their own way.

## 1.3.0 ##

* Added support for unique key (via salt) and IV. (@danpal & @rcook)

## 1.2.3 ##

* Added support for passing blocks to `encrypt` and `decrypt`. (@shuber)
* Changed raising an exception if key is missing or empty. (@shuber)
