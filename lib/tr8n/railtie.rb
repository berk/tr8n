#--
# Copyright (c) 2010-2011 Michael Berkovich
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

require 'rails'
require 'pp'

[
 ".",
 "./tokens"
].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
      require(file)
    end
end

require File.join(File.dirname(__FILE__), 'extensions/array_extension')
require File.join(File.dirname(__FILE__), 'extensions/date_extension')
require File.join(File.dirname(__FILE__), 'extensions/fixnum_extension')
require File.join(File.dirname(__FILE__), 'extensions/hash_extension')
require File.join(File.dirname(__FILE__), 'extensions/string_extension')
require File.join(File.dirname(__FILE__), 'extensions/time_extension')
require File.join(File.dirname(__FILE__), 'extensions/action_view_extension')
require File.join(File.dirname(__FILE__), 'extensions/action_controller_extension')

module Tr8n
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'tr8n' do |app|
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Tr8n::ActionViewExtension
      end
      ActiveSupport.on_load(:action_controller) do
        include Tr8n::ActionControllerExtension
      end      
    end
  end
end