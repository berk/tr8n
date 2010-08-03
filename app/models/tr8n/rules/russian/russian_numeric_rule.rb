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

# This is an example of how you could implement the transform 
# function for the default transform_tokens 
# if your default site language is Russian

class Tr8n::RussianNumericRule < Tr8n::NumericRule

  # FORM: [object, (ends in 1, but not in 11), (ends in 2, 3, 4 and is not 12, 13, 14), (ends in 0, 5, 6, 7, 8, 9, 11, 12, 13, 14)]
  # {count | собака, собаки, собак}
  # {count | сообщение, сообщения, сообщений}
  def self.transform(*args)
    if args.size != 4
      raise Tr8n::Exception.new("Invalid transform arguments for number token")
    end
    
    object = args[0]
    object_value = number_token_value(object)
    unless object_value
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:numeric_rule][:object_method]}")
    end

    string_value = object_value.to_s

    if string_value.last == "1" and string_value != "11"
      return args[1]
    elsif ['2', '3', '4'].include?(string_value.last) and not ['12', '13', '14'].include?(string_value)
      return args[2]
    end
    
    args[3]
  end
  
  # params: [singular form, plural form1, plural form2]
  def self.default_transform(*args)
    if args.size != 3
      raise Tr8n::Exception.new("Invalid transform arguments for number token")
    end
    
    args[2]
  end  
  
end
