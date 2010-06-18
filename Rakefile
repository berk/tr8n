require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
 require 'jeweler'
 Jeweler::Tasks.new do |s|
   s.name = "tr8n"
   s.summary = %Q{Crowd-sourced translation for Rails.}
   s.email = "michael@geni.com"
   s.homepage = "http://github.com/berk/tr8n"
   s.description = "Crowd-sourced translation and localization for Rails"
   s.authors = ["Michael Berkovich"]
 end
 Jeweler::GemcutterTasks.new
rescue LoadError
 puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new do |t|
 t.libs << 'lib'
 t.pattern = 'test/**/*_test.rb'
 t.verbose = false
end

Rake::RDocTask.new do |rdoc|
 rdoc.rdoc_dir = 'rdoc'
 rdoc.title    = 'tr8n'
 rdoc.options << '--line-numbers' << '--inline-source'
 rdoc.rdoc_files.include('README*')
 rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
 require 'rcov/rcovtask'
 Rcov::RcovTask.new do |t|
   t.libs << 'test'
   t.test_files = FileList['test/**/*_test.rb']
   t.verbose = true
 end
rescue LoadError
end

task :default => :test