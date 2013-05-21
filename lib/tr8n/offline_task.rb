#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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

module Tr8n
  class OfflineTask

    def self.schedule(obj, method_name, opts = {})
      # default implementation just passes the call right back
      # you can monkey patch this class to use an offline system of your preference
      if obj.is_a?(String) or obj.is_a?(Symbol)
        obj = obj.constantize
      end

      # Tr8n::Logger.logger(:offline).debug("*********************")
      # Tr8n::Logger.logger(:offline).debug(obj.inspect)
      # Tr8n::Logger.logger(:offline).debug(method_name)
      # Tr8n::Logger.logger(:offline).debug(opts.inspect)
      # Tr8n::Logger.logger(:offline).debug(caller.to_s)

      if Tr8n::Config.offline_task_method == "delayed_jobs"
        obj.delay.send(method_name, opts)
      else
        obj.send(method_name, opts)
      end
    end

  end 
end