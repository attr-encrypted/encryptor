Encryptor
=========

A simple wrapper for the standard ruby OpenSSL library


Installation
------------

	gem install shuber-encryptor --source http://gems.github.com


Usage
-----

	secret_key = Digest::SHA256.hexdigest('a secret key')
	encrypted_value = Huberry::Encryptor.encrypt(:value => 'some string to encrypt', :key => secret_key) # '������{)��q�ށ�ܣ��q���Au/�ޜP'
	decrypted_value = Huberry::Encryptor.decrypt(:value => encrypted_value, :key => secret_key) # 'some string to encrypt'

You may also pass the `:iv` and `:algorithm` options but they are not required. If an algorithm is not specified, the Encryptor uses
the algorithm found at `Huberry::Encryptor.default_options[:algorithm]` which is `aes-256-cbc` by default. You can change the default options 
by overwriting or merging this attribute:

	Huberry::Encryptor.default_options.merge!(:algorithm => 'bf', :key => 'some default secret key')

Run `openssl list-cipher-commands` in your terminal to view a list all cipher algorithms that are supported on your platform.

	aes-128-cbc
	aes-128-ecb
	aes-192-cbc
	aes-192-ecb
	aes-256-cbc
	aes-256-ecb
	base64
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


Contact
-------

Problems, comments, and suggestions all welcome: [shuber@huberry.com](mailto:shuber@huberry.com)