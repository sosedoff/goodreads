Gem::Specification.new do |s|
  s.name = "goodreads"
  s.version = "0.1.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Sosedoff"]
  s.date = "2011-01-05"
  s.description = "Simplified client to the Goodreads.com API"
  s.email = "dan.sosedoff@gmail.com"
  s.files = [
    "lib/goodreads.rb",
    "lib/goodreads/goodreads.rb",
    "lib/goodreads/client.rb",
    "lib/goodreads/record.rb"
  ]
  s.homepage = "http://github.com/sosedoff/goodreads"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.7"
  s.summary = "Simplified client to the Goodreads.com API"
end