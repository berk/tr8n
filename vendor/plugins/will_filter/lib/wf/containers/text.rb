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

class Wf::Containers::Text < Wf::FilterContainer

  def self.operators
    [:is, :is_not, :contains, :does_not_contain, :starts_with, :ends_with]
  end

  def validate
    # always valid, even when it is empty
  end

  def sql_condition
    return [" #{condition.full_key} = ? ", value]                 if operator == :is
    return [" #{condition.full_key} <> ? ", value]                if operator == :is_not
    return [" #{condition.full_key} like ? ", "%#{value}%"]       if operator == :contains
    return [" #{condition.full_key} not like ? ", "%#{value}%"]   if operator == :does_not_contain
    return [" #{condition.full_key} like ? ", "#{value}%"]        if operator == :starts_with
    return [" #{condition.full_key} like ? ", "%#{value}"]        if operator == :ends_with
  end

end
