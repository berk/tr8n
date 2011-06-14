# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake/testtask'

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.libs << 'test'
end

begin
 require 'jeweler'
 Jeweler::Tasks.new do |s|
   s.name = "tr8n"
   s.summary = "Crowd-sourced translation engine for Rails."
   s.email = "theiceberk@gmail.com"
   s.homepage = "http://github.com/berk/tr8n"
   s.description = "Crowd-sourced translation engine for Rails."
   s.authors = ["Michael Berkovich"]
 end
 Jeweler::GemcutterTasks.new
rescue LoadError
 puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

#require File.expand_path('../config/application', __FILE__)
#require 'rake'
#
#Tr8n::Application.load_tasks
