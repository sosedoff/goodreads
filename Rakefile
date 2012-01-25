require 'bundler'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.verbose = false
end

task :default => :test

desc "Run authentication tests"
RSpec::Core::RakeTask.new(:auth) do |t|
  t.pattern = './spec/**/authentication_spec.rb'
end
