Gem::Specification.new do |s|
  s.name = 'rscript'
  s.version = '0.3.4'
  s.summary = 'rscript previously known as rcscript, reads Ruby code which is embedded within an rscript XML file.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rscript.rb', 'lib/rscript_base.rb']
  s.add_runtime_dependency('hashcache', '~> 0.2', '>=0.2.10')
  s.add_runtime_dependency('rxfhelper', '~> 0.3', '>=0.3.0')
  s.add_runtime_dependency('rexle', '~> 1.3', '>=1.3.34')
  s.signing_key = '../privatekeys/rscript.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rscript'
  s.required_ruby_version = '>= 2.1.0'
end
