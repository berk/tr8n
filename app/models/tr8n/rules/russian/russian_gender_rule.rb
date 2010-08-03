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

class Tr8n::RussianGenderRule < Tr8n::GenderRule

  # FORM: [object, male, female, unknown]
  # {user | he, she}
  # {user | he, she, he/she}
  def self.transform(*args)
    unless [3, 4].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for gender token")
    end
    
    object = args[0]
    object_value = gender_token_value(object)
    
    unless object_value
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:gender_rule][:object_method]}")
    end
    
    if (object_value == gender_object_value_for("male"))
      return args[1]
    elsif (object_value == gender_object_value_for("female"))
      return args[2]
    end

    return args[3] if args.size == 4
    
    "#{args[1]}/#{args[2]}"  
  end
  
  # params: [male form, female form, unknown form]
  def self.default_transform(*args)
    unless [2, 3].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for gender token")
    end
    
    # always use masculine form for the translation label
    args[0]
  end  

end
