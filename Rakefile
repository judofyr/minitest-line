require 'bundler/setup'
require 'rake/testtask'

task :default => :test

desc 'Runs tests'
task :test do
  test = 'test/test_line.rb'
  ruby File.expand_path(test)
  ruby test
end
