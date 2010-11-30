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

class Wf::Containers::NumericRange < Wf::FilterContainer

  attr_accessor :start_value, :end_value

  def self.operators
    [:is_in_the_range]
  end

  def initialize(filter, criteria_key, operator, values)
    super(filter, criteria_key, operator, values)

    @start_value = values[0]
    @end_value = values[1] if values.size > 1
  end

  def validate
    return "Start value must be provided" if start_value.blank?
    return "Start value must be numeric"  unless is_numeric?(start_value)
    return "End value must be provided"   if end_value.blank?
    return "End value must be numeric"    unless is_numeric?(end_value)
  end

  def numeric_start_value
    start_value.to_i
  end

  def numeric_end_value
    end_value.to_i
  end

  def sql_condition
    return [" (#{condition.full_key} >= ? and #{condition.full_key} <= ?) ", numeric_start_value, numeric_end_value] if operator == :is_in_the_range
  end
  
end
