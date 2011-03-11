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

require 'bundler'
Bundler::GemHelper.install_tasks

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

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