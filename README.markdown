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
	decrypted_value = Huberry::Encryptor.encrypt(:value => encrypted_value, :key => secret_key) # 'some string to encrypt'

You may also pass the :iv and :algorithm options but they are not required. If an algorithm is not specified, the Encryptor uses
the algorithm found at `Huberry::Encryptor.default_algorithm` which is `aes-256-cbc` by default. You can change the default algorithm 
by overwriting this attribute

	Huberry::Encryptor.default_algorithm = 'bf'

Run `openssl list-cipher-commands` in your terminal to view a list all cipher algorithms that are supported on your platform


Contact
-------

Problems, comments, and suggestions all welcome: [shuber@huberry.com](mailto:shuber@huberry.com)