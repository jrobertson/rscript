Gem::Specification.new do |s|
  s.name = 'rscript'
  s.version = '0.1.4'
  s.summary = 'rscript previously known as rcscript, reads Ruby code which is embedded within an rscript XML file.'
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('hashcache')
end
