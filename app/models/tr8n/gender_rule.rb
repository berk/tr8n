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

class Tr8n::GenderRule < Tr8n::LanguageRule
  
  def self.description
    "token object may have a gender, which"
  end
  
  def self.dependency
    "gender" 
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:gender_rule][:token_suffixes]
  end

  def self.default_rules_for(language)
    Tr8n::Config.default_gender_rules(language.locale)
  end
  
  def self.operator_options
    [["is", "is"], ["is not", "is_not"]]
  end

  def self.gender_options
    [["a male", "male"], ["a female", "female"], ["neutral", "neutral"], ["unknown", "unknown"]]
  end
  
  def self.gender_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_rule][:object_method])
  end
  
  def gender_token_value(token)
    self.class.gender_token_value(token)
  end

  def self.gender_object_value_for(type)
    Tr8n::Config.rules_engine[:gender_rule][:method_values][type]
  end

  def gender_object_value_for(type)
    self.class.gender_object_value_for(type)
  end
  
  # FORM: [object, male, female, unknown]
  # {user | registered on}
  # {user | he, she}
  # {user | he, she, he/she}
  def self.transform(*args)
    unless [2, 3, 4].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for gender token")
    end
    
    return args[1] if args.size == 2
    
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
    unless [1, 2, 3].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for gender token")
    end
    
    # always use masculine form for the translation label
    args[0]
  end  
  
  def evaluate(token)
    token_value = gender_token_value(token)
    return false unless token_value
    
    if definition[:operator] == "is"
      return true if token_value == gender_object_value_for(definition[:value])
    elsif definition[:operator] == "is_not"
      return true if token_value != gender_object_value_for(definition[:value])
    end
    
    false    
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used to describe a context of a given translation
  def description
    if definition[:operator] == "is"
      return "is a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "has a neutral gender" if "neutral" == definition[:value]
      return "has an unknown gender" if "unknown" == definition[:value]
    end
    
    if definition[:operator] == "is_not"
      return "is not a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "does not have a neutral gender" if "neutral" == definition[:value]
      return "does not have an unknown gender" if "unknown" == definition[:value]
    end

    "has an unknown rule"
  end

end
