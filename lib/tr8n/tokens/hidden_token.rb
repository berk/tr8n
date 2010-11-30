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

####################################################################### 
# 
# Hidden Token Forms:
#
# {_he_she} 
# {_posted__items}
#
#  '_' escaped as '/'
#  '__' escaped as '__'
# 
# Hidden tokens cannot have rules and are there for default language
# substitutions only
#
####################################################################### 


class Tr8n::Tokens::HiddenToken < Tr8n::Token
  
  def self.expression
    /(\{_[\w]+\})/
  end

  def allowed_in_translation?
    false
  end

  def supports_cases?
    false
  end

  def dependant?
    false
  end

  def dependency_rules
    []
  end

  def language_rule
    nil
  end

  # return humanized form
  def prepare_label_for_translator(label)
    label.gsub(full_name, humanized_name)
  end

  # return humanized form
  def prepare_label_for_suggestion(label, index)
    label.gsub(full_name, humanized_name)
  end
  
  def humanized_name
    @humanized_name ||= begin
      hnm = name[1..-1].clone
      hnm.gsub!('__', ' ')
      hnm.gsub!('_', '/')
      hnm
    end
  end
  
end
