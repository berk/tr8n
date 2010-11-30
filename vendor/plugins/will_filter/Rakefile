#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

begin
 require 'jeweler'
 Jeweler::Tasks.new do |s|
   s.name = "will_filter"
   s.summary = %Q{Filtering framework for Rails AcitveRecord models.}
   s.email = "michael@geni.com"
   s.homepage = "http://github.com/berk/will_filter"
   s.description = "Filtering framework for Rails AcitveRecord models"
   s.authors = ["Michael Berkovich"]
 end
 Jeweler::GemcutterTasks.new
rescue LoadError
 puts "Jeweler not available. Install it with: sudo gem install jeweler"
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

desc 'Test the blogify plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the blogify plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Blogify'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Default: run unit tests.'
task :default => :test

task :unpack_gem do
  require "rubygems/installer"
  source_file = File.expand_path("#{File.dirname(__FILE__)}/pkg/will_filter-0.1.0.gem")
  puts source_file
  
  target_dir = File.expand_path("#{File.dirname(__FILE__)}/pkg/unpacked")
  puts target_dir

  rm_rf target_dir
  mkdir_p target_dir
  
  Gem::Installer.new(source_file).unpack(target_dir)    
end
