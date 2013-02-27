require File.expand_path('../lib/goodreads/version', __FILE__)
Gem::Specification.new do |s|
  s.name        = "goodreads"
  s.version     = Goodreads::VERSION.dup
  s.summary     = "Goodreads API wrapper"
  s.description = "Simple wrapper for the Goodreads API"
  s.homepage    = "http://github.com/sosedoff/goodreads"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]

  s.add_development_dependency 'webmock',   '~> 1.6'
  s.add_development_dependency 'rake',      '~> 10'
  s.add_development_dependency 'rspec',     '~> 2.12'
  s.add_development_dependency 'simplecov', '~> 0.4'
  s.add_development_dependency 'yard',      '~> 0.6'

  s.add_runtime_dependency 'rest-client',   '~> 1.6'
  s.add_runtime_dependency 'hashie',        '~> 2'
  s.add_runtime_dependency 'activesupport', '~> 3'
  s.add_runtime_dependency 'i18n',          '~> 0.5'
  s.add_runtime_dependency 'oauth',         '~> 0.4'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end