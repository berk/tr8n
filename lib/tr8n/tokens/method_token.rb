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
# Method Token Forms
#
# {user.name}  
# {user.name:gender}
# 
####################################################################### 

class Tr8n::MethodToken < Tr8n::Token
  
  def self.expression
    /(\{[^_][\w]+(\.[\w]+)(:[\w]+)?\})/
  end

  def object_name
    @object_name ||= name.split(".").first
  end

  def object_method_name
    @object_method_name ||= name.split(".").last
  end

  def substitute(label, values = {}, options = {}, language = Tr8n::Config.current_language)
    object = values[object_name.to_sym]
    raise Tr8n::TokenException.new("Missing value for a token: #{full_name}") unless object
    object_value = sanitize_token_value(object.send(object_method_name), options.merge(:sanitize_values => true))
    label.gsub(full_name, object_value)
  end
  
end
