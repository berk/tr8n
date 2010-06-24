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

require 'model_filter'

class Tr8n::BaseFilter < ModelFilter

  def initialize(class_name, identity)
    super(class_name, identity)
  end

  def predefined_filters(profile)
    [
      ["Created Today", "created_today"],
      ["Updated Today", "updated_today"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key = filter_name
 
    if (filter_name == "created_today")
      filter.add_condition(:created_at, :is_on, Date.today)
      return filter
    end

    if (filter_name == "updated_today")
      filter.add_condition(:updated_at, :is_on, Date.today)
      return filter
    end

    filter
  end  
end
