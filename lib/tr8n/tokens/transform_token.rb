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
# Transform Token Form
#
# {count | message}   - will not include count: "messages" 
# {count | message, messages} 
# {count:number | message, messages} 
# {user:gender | he, she, he/she}
# {now:date | did, does, will do}
# {users:list | all male, all female, mixed genders}
#
# {count || message, messages}  - will include count:  "5 messages" 
# 
####################################################################### 

class Tr8n::TransformToken < Tr8n::Token
    
  def self.expression
    /(\{[^_][\w]+(:[\w]+)?(::[\w]+)?\s*\|\|?[^{^}]+\})/
  end

  def name
    @name ||= declared_name.split('|').first.split(':').first.strip
  end
  
  def sanitized_name
    "{#{name}}"
  end

  def pipe_separator
    @pipe_separator ||= (full_name.index("||") ? "||" : "|") 
  end
  
  def piped_params
    @piped_params ||= declared_name.split(pipe_separator).last.split(",").collect{|param| param.strip}
  end
  
  def allowed_in_translation?
    pipe_separator == "||" 
  end
  
  def token_object(object)
    # token is an array
    if object.is_a?(Array)
      # if you provided an array, it better have some values
      if object.empty?
        return raise Tr8n::TokenException.new("Invalid array object for a transform token: #{full_name}")
      end

      # if the first item in the array is an object, process it
      return object.first
    end

    object    
  end
  
  def validate_language_rule
    unless dependant?
      raise Tr8n::TokenException.new("Unknown dependency type for #{full_name} token in #{original_label}; no way to apply the transform method.")
    end
    
    unless language_rule.respond_to?(:default_transform)
      raise Tr8n::TokenException.new("#{language_rule.class.name} does not respond to the default transform method.")
    end
  end
  
  # return with the default transform substitution
  def prepare_label_for_translator(label)
    validate_language_rule
    
    substitution_value = "" 
    substitution_value << sanitized_name if allowed_in_translation?
    substitution_value << " " unless substitution_value.blank?
    substitution_value << language_rule.default_transform(*piped_params)
    
    label.gsub(full_name, substitution_value)    
  end

  # return only the internal part
  def prepare_label_for_suggestion(label, index)
    validate_language_rule
    label.gsub(full_name, language_rule.default_transform(*piped_params))    
  end
  
  def substitute(label, values = {}, options = {}, language = Tr8n::Config.current_language)
    # only the default language allows for the transform tokens
    return label unless language.default?
    
    object = values[name_key]
    unless object
      raise Tr8n::TokenException.new("Missing value for a token: #{full_name}")
    end
    
    validate_language_rule
    
    params = [token_object(object)] + piped_params
    substitution_value = "" 
    substitution_value << token_value(object, options, language) if allowed_in_translation?
    substitution_value << " " unless substitution_value.blank?
    substitution_value << language_rule.transform(*params)
    
    label.gsub(full_name, substitution_value)    
  end
  
end
