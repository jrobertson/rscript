Gem::Specification.new do |s|
  s.name = 'rscript'
  s.version = '0.1.18'
  s.summary = 'rscript previously known as rcscript, reads Ruby code which is embedded within an rscript XML file.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('hashcache')
  s.add_dependency('rxfhelper') 
  s.signing_key = '../privatekeys/rscript.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rscript'
end
