Gem::Specification.new do |s|
  s.name    = 'encryptor'
  s.version = '1.0.0'
  s.date    = '2009-01-07'
  
  s.summary     = 'A simple wrapper for the standard ruby OpenSSL library'
  s.description = 'A simple wrapper for the standard ruby OpenSSL library'
  
  s.author   = 'Sean Huber'
  s.email    = 'shuber@huberry.com'
  s.homepage = 'http://github.com/shuber/encryptor'
  
  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.markdown']
  
  s.require_paths = ['lib']
  
  s.files = %w(
    CHANGELOG
    lib/encryptor.rb
    MIT-LICENSE
    Rakefile
    README.markdown
  )
  
  s.test_files = %w(
    test/encryptor_test.rb
  )
end