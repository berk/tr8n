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


#require "JSON"
#require 'digest/md5'
require 'pp'

["lib/core_ext/**",
 "lib/tr8n",
 "lib/tr8n/tokens",
 "app/models/tr8n", 
 "app/models/tr8n/filters", 
 "app/models/tr8n/metrics",
 "app/models/tr8n/rules",
 "app/models/tr8n/test",
 "app/models/tr8n/rules/ext"].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
      require_or_load file
    end
end

Tr8n::Config.models.each do |model|
  model.extend(Tr8n::ActiveDumper)
end

Rails.configuration.after_initialize do
  begin
    ApplicationController.send(:include, Tr8n::CommonMethods)
    ApplicationHelper.send(:include, Tr8n::HelperMethods)
  rescue NameError => er
    pp er
  end
end

