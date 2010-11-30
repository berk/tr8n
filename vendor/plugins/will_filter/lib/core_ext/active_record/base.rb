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

class ActiveRecord::Base

  def self.filter(opts = {})
    if ActiveRecord::Base == self.class
      raise Wf::FilterException.new("Cannot apply filter to the ActiveRecord::Base object")
    end

    params = opts[:params] || {}
    
    if opts[:filter]
      case opts[:filter].class.name
        when "String" then filter_class = opts[:filter].constantize
        when "Symbol" then filter_class = opts[:filter].to_s.camelcase.constantize
        else filter_class = opts[:filter]
      end
    else
      filter_class = Wf::Filter
    end
  
    filter_class.new(self).deserialize_from_params(params).results
  end
  
end
