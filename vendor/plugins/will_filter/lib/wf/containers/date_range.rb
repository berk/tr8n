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

class Wf::Containers::DateRange < Wf::FilterContainer

  def self.operators
    [:is_in_the_range]
  end

  def initialize(filter, criteria_key, operator, values)
    super(filter, criteria_key, operator, values)
    @start_date = values[0]
    @end_date = values[1] if values.size > 1
  end

  def validate
    return "Start value must be provided" if @start_date.blank?
    return "Start value must be a valid date (2008-01-01)" if date(@start_date) == nil
    return "End value must be provided" if @end_date.blank?
    return "End value must be a valid date (2008-01-01)" if date(@end_date) == nil
  end

  def date(dt)
    Date.parse(dt)
  rescue ArgumentError
    nil
  end

  def sql_condition
    return [" (#{condition.full_key} >= ? and #{condition.full_key} <= ?) ", date(@start_date), date(@end_date)] if operator == :is_in_the_range
  end
  
end
