Gem::Specification.new do |s|
  s.name = 'rscript'
  s.version = '0.6.1'
  s.summary = 'Reads or executes a job contained within a ' + 
     'package (XML document), whereby the package is typically read from a URL'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rscript.rb', 'lib/rscript_base.rb']
  s.add_runtime_dependency('hashcache', '~> 0.2', '>=0.2.10')
  s.add_runtime_dependency('rxfhelper', '~> 0.8', '>=0.8.0')
  s.add_runtime_dependency('rexle', '~> 1.4', '>=1.4.12')
  s.signing_key = '../privatekeys/rscript.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/rscript'
  s.required_ruby_version = '>= 2.1.0'
end
