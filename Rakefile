require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.libs = ['lib', 'test']
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
