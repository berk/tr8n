#--
# Copyright (c) 2010-2012 Justin Balthrop
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

require File.expand_path(File.dirname(__FILE__) + "/extender") 

module Tr8n
  class DumperException < StandardError; end
  module ActiveDumper
    extend Tr8n::Extender

    module InstanceMethods
      def _dump(ignored)
        data = {:attributes => @attributes, :new_record => @new_record}
        Marshal.dump(data)
      end
    end
  
    module ClassMethods
      def _load(str)
        data = Marshal.load(str)
      
        raise Tr8n::Exception, 'invalid format' if not data.kind_of?(Hash) or data.keys.to_set != [:attributes, :new_record].to_set

        instance = new
        instance.instance_variable_set(:@attributes, data[:attributes])
        instance.instance_variable_set(:@new_record, data[:new_record])
        instance
      end
    end
  end
end