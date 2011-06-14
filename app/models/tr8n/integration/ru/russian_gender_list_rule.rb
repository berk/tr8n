#--
# Copyright (c) 2010-2011 Michael Berkovich
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

class Tr8n::RussianGenderListRule < Tr8n::GenderListRule

  # params: [object, one element male, one element female, one element unknown, at least two elements]
  # {user_list | one element male, one element female, one element unknown, at least two elements}

  # TODO: finish implementation
  def self.transform(*args)
    unless args.size == 3
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    list_size = list_size_token_value(object)

    unless list_size
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:gender_list_rule][:object_method]}")
    end
    
    list_size = list_size.to_i
    
    return args[1] if list_size == 1
    return args[2] if list_size >= 2
    
    # should we raise an exception here if the list is empty?
    ""  
  end  
  
  # params: [one element, at least two elements]
  def self.default_transform(*args)
    unless args.size == 2
      raise Tr8n::Exception.new("Invalid transform arguments for list token")
    end
    
    args[1]
  end  

end
