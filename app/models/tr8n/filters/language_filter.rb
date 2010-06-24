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

class Tr8n::LanguageFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::Language', identity)
  end

  def definition
    defs = super  
    defs[:fallback_language_id][:is] = :list
    defs[:fallback_language_id][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :fallback_language_id
      return Tr8n::Language.filter_options 
    end

    return []
  end

  def default_order
    'english_name'
  end
  
  def default_order_type
    'asc'
  end

  def predefined_filters(profile)
    super(profile) + [
      ["Enabled Languages", "enabled"],
      ["Disabled Languages", "disabled"],
      ["Left-to-Right Languages", "left"],
      ["Right-to-Left Languages", "right"]
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)

    case filter_name
      when "enabled"
        filter.add_condition(:enabled, :is, '1')
      when "disabled"
        filter.add_condition(:enabled, :is, '0')
      when "left"
        filter.add_condition(:right_to_left, :is, '0')
      when "right"
        filter.add_condition(:right_to_left, :is, '1')
    end

    filter.empty? ? nil : filter
  end

end
