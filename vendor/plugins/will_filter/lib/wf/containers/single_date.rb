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

class Wf::Containers::SingleDate < Wf::FilterContainer

  def self.operators
    [:is_on]
  end

  def template_name
    'date'
  end

  def validate
    return "Value must be provided" if value.blank?
    return "Value must be a valid date (2008-01-01)" if start_date_time == nil
  end

  def start_date_time
    Date.parse(value).to_time
  rescue ArgumentError
    nil
  end

  def end_date_time
    (start_date_time + 1.day)
  rescue ArgumentError
    nil
  end

  def sql_condition
    return [" #{condition.full_key} >= ? and #{condition.full_key} < ? ", start_date_time, end_date_time]  if operator == :is_on
  end

end
