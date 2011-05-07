require File.expand_path('../lib/goodreads/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "goodreads"
  s.version     = Goodreads::VERSION.dup
  s.summary     = "Goodreads API wrapper"
  s.description = "Simple wrapper for the Goodreads API"
  s.homepage    = "http://github.com/sosedoff/goodreads"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'webmock', '~> 1.6'
  s.add_development_dependency 'rake', '~> 0.8'
  s.add_development_dependency 'rspec', '~> 2.5'
  
  s.add_runtime_dependency 'rest-client', '~> 1.6.1'
  s.add_runtime_dependency 'hashie', '~> 1.0.0'
  s.add_runtime_dependency 'activesupport', '~> 3.0.0'
  s.add_runtime_dependency 'i18n', '~> 0.5'
  
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
  
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=
end