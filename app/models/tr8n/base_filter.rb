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

class Tr8n::BaseFilter < Wf::Filter

  def definition
    meta = super
    meta.keys.each do |key|
      parts = key.to_s.split(".")
      next unless parts.last.index("language_id")
      meta[key][:is] = :list
      meta[key][:is_not] = :list
    end
    meta
  end

  def value_options_for(criteria_key)
    parts = criteria_key.to_s.split(".")
    if parts.last.index("language_id")
      return Tr8n::Language.filter_options
    end

    return []
  end

  def default_filters
    [
      ["Created Today", "created_today"],
      ["Updated Today", "updated_today"]
    ]
  end

  def default_filter_conditions(key)
    return [:created_at, :is_on, Date.today] if (key == "created_today")
    return [:updated_at, :is_on, Date.today] if (key == "updated_today")
  end
  
  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
end
