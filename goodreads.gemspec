require File.expand_path("../lib/goodreads/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "goodreads"
  spec.version     = Goodreads::VERSION.dup
  spec.summary     = "Goodreads API wrapper"
  spec.description = "Simple wrapper for the Goodreads API"
  spec.homepage    = "http://github.com/sosedoff/goodreads"
  spec.authors     = ["Dan Sosedoff"]
  spec.email       = ["dan.sosedoff@gmail.com"]
  spec.license     = "MIT"

  spec.add_development_dependency "webmock",   "~> 2.0"
  spec.add_development_dependency "rake",      "~> 10"
  spec.add_development_dependency "rspec",     "~> 2.12"
  spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_development_dependency "yard",      "~> 0.9"

  spec.add_runtime_dependency "rest-client",   "~> 2.0"
  spec.add_runtime_dependency "hashie",        "~> 4.1.0"
  spec.add_runtime_dependency "activesupport", ">= 3.0"
  spec.add_runtime_dependency "i18n",          ">= 0.6", "< 2"
  spec.add_runtime_dependency "oauth",         "~> 0.4"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
